/**
 * 音频管理器
 * 负责播放背景音乐和音效
 */
import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import audio from '@ohos.multimedia.audio';
import resourceManager from '@ohos.resourceManager';
import preferences from '@ohos.data.preferences';

export class AudioManager {
  private static instance: AudioManager;
  private bgmPlayer: media.AVPlayer | null = null;
  private soundPlayer: media.AVPlayer | null = null;
  private bgmVolume: number = 0.27; // 默认27%
  private soundVolume: number = 0.27; // 默认27%
  private bgmEnabled: boolean = true;
  private soundEnabled: boolean = true;
  private context?: common.UIAbilityContext;
  private currentBGMFd: resourceManager.RawFileDescriptor | null = null;
  private currentSoundFd: resourceManager.RawFileDescriptor | null = null;
  private currentBGMPath: string = ''; // 跟踪当前播放的BGM路径
  private preferencesStore: preferences.Preferences | null = null; // 数据持久化存储

  private constructor() {}

  static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }

  /**
   * 设置Context（必须在使用前调用）
   */
  async setContext(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    // 初始化数据持久化存储
    await this.initPreferences();
  }

  /**
   * 初始化数据持久化
   */
  private async initPreferences(): Promise<void> {
    try {
      if (!this.context) {
        console.error('[PREFERENCES] Context未设置');
        return;
      }
      
      // 创建或获取 preferences 实例
      this.preferencesStore = await preferences.getPreferences(this.context, 'audio_settings');
      console.log('[PREFERENCES] 数据存储初始化成功');
      
      // 加载保存的音量设置
      await this.loadVolumeSettings();
    } catch (err) {
      console.error('[PREFERENCES] 初始化失败:', err);
    }
  }

  /**
   * 加载保存的音量设置
   */
  private async loadVolumeSettings(): Promise<void> {
    try {
      if (!this.preferencesStore) {
        console.warn('[PREFERENCES] 存储未初始化');
        return;
      }
      
      // 读取BGM音量
      const savedBgmVolume = await this.preferencesStore.get('bgm_volume', 0.27) as number;
      this.bgmVolume = Math.max(0, Math.min(1, savedBgmVolume));
      console.log(`[PREFERENCES] 加载BGM音量: ${this.bgmVolume}`);
      
      // 读取音效音量
      const savedSoundVolume = await this.preferencesStore.get('sound_volume', 0.27) as number;
      this.soundVolume = Math.max(0, Math.min(1, savedSoundVolume));
      console.log(`[PREFERENCES] 加载音效音量: ${this.soundVolume}`);
    } catch (err) {
      console.error('[PREFERENCES] 加载音量设置失败:', err);
    }
  }

  /**
   * 保存音量设置到持久化存储
   */
  private async saveVolumeSettings(): Promise<void> {
    try {
      if (!this.preferencesStore) {
        console.warn('[PREFERENCES] 存储未初始化，无法保存');
        return;
      }
      
      // 保存BGM音量
      await this.preferencesStore.put('bgm_volume', this.bgmVolume);
      await this.preferencesStore.put('sound_volume', this.soundVolume);
      
      // 持久化到磁盘
      await this.preferencesStore.flush();
      console.log(`[PREFERENCES] 音量设置已保存: BGM=${this.bgmVolume}, Sound=${this.soundVolume}`);
    } catch (err) {
      console.error('[PREFERENCES] 保存音量设置失败:', err);
    }
  }

  /**
   * 获取当前BGM音量
   */
  getBGMVolume(): number {
    return this.bgmVolume;
  }

  /**
   * 获取当前音效音量
   */
  getSoundVolume(): number {
    return this.soundVolume;
  }

  /**
   * 检测音频设备（简化版）
   */
  checkAudioDevices(): void {
    // 简化：仅输出日志，不实际检测设备
    // 避免使用可能不存在的 API
    console.log('[AUDIO_DEBUG] 音频系统初始化中...');
  }

  /**
   * 播放背景音乐
   */
  async playBGM(resourcePath: string): Promise<void> {
    if (!this.bgmEnabled || !this.context) {
      console.log('[BGM_DEBUG] BGM disabled or no context');
      return;
    }

    try {
      console.log(`[BGM_DEBUG] 开始播放BGM: ${resourcePath}`);
      
      // ✅ 检查是否已经在播放同样的BGM
      if (this.currentBGMPath === resourcePath && this.bgmPlayer && this.bgmPlayer.state === 'playing') {
        console.log('[BGM_DEBUG] 已在播放相同BGM，跳过重复播放');
        return;
      }
      
      // 停止当前BGM（增加状态校验）
      if (this.bgmPlayer) {
        try {
          const currentState = this.bgmPlayer.state;
          console.log(`[BGM_DEBUG] 当前播放器状态: ${currentState}`);
          
          // 只在播放器处于可停止状态时调用 stop
          if (currentState === 'playing' || currentState === 'paused' || 
              currentState === 'prepared' || currentState === 'completed') {
            await this.bgmPlayer.stop();
            console.log('[BGM_DEBUG] 播放器已停止');
          }
          
          await this.bgmPlayer.release();
          console.log('[BGM_DEBUG] BGM播放器已释放');
        } catch (e) {
          console.log('[BGM_DEBUG] Error stopping BGM:', e);
        }
        this.bgmPlayer = null;
        this.currentBGMFd = null;
        this.currentBGMPath = ''; // 清除当前BGM路径
      }

      // 创建新的播放器
      this.bgmPlayer = await media.createAVPlayer();
      console.log('[BGM_DEBUG] AVPlayer创建成功');
      
      // ✅ 设置初始音量（使用setVolume方法）
      this.bgmPlayer.setVolume(this.bgmVolume);
      console.log(`[BGM_DEBUG] 初始音量已设置: ${this.bgmVolume}`);
      
      // 设置状态变化监听器（必须在设置fdSrc之前）
      this.bgmPlayer.on('stateChange', async (state: string) => {
        console.log(`[BGM_STATE] 状态变化: ${state}`);
        
        if (state === 'error') {
          console.error(`[BGM_STATE] 错误状态，当前state: ${this.bgmPlayer?.state}`);
        }
        
        // ✅ 关键修复：在 initialized 状态时调用 prepare
        if (state === 'initialized') {
          console.log('[BGM_STATE] 已初始化，开始准备播放');
          try {
            await this.bgmPlayer?.prepare();
            console.log('[BGM_STATE] prepare()已调用');
          } catch (e) {
            console.error('[BGM_STATE] prepare失败:', e);
          }
        }
        
        if (state === 'prepared') {
          console.log('[BGM_STATE] 准备完成，设置循环并开始播放');
          try {
            // ✅ 在 prepared 状态设置循环播放
            if (this.bgmPlayer) {
              this.bgmPlayer.loop = true;
              console.log('[BGM_STATE] 循环播放已启用');
              
              // ✅ 关键修复：在 prepared 状态再次设置音量，确保生效
              this.bgmPlayer.setVolume(this.bgmVolume);
              console.log(`[BGM_STATE] 音量已在prepared状态设置: ${this.bgmVolume}`);
            }
            
            await this.bgmPlayer?.play();
            console.log('[BGM_STATE] 播放指令已发送');
          } catch (e) {
            console.error('[BGM_STATE] 播放失败:', e);
          }
        }
        
        if (state === 'playing') {
          console.log('[BGM_STATE] 正在播放中 🎵');
          // ✅ 保存当前播放的BGM路径
          this.currentBGMPath = resourcePath;
        }
      });

      this.bgmPlayer.on('error', (err: Error) => {
        console.error('[BGM_STATE] 播放错误:', err.message);
      });
      
      // 使用文件描述符方式加载资源
      const fd = await this.context.resourceManager.getRawFd(resourcePath);
      console.log(`[BGM_DEBUG] 资源路径: ${resourcePath}`);
      console.log(`[BGM_DEBUG] 文件描述符: fd=${fd.fd}, offset=${fd.offset}, length=${fd.length}`);
      console.log(`[BGM_DEBUG] fd有效性: ${fd.fd >= 0}`);
      
      if (fd.fd < 0) {
        console.error('[BGM_DEBUG] 文件描述符无效，停止播放');
        return;
      }
      
      // 保存fd引用以便后续关闭
      this.currentBGMFd = fd;
      
      // ✅ 设置 fdSrc，这会触发异步状态变化到 initialized
      this.bgmPlayer.fdSrc = {
        fd: fd.fd,
        offset: fd.offset,
        length: fd.length
      };
      console.log('[BGM_DEBUG] fdSrc已设置，触发状态变化到initialized...');
      console.log('[BGM_DEBUG] 等待状态机自动处理 initialized → prepared → playing');
      
      // ❌ 不要在这里调用 prepare()！
      // AVPlayer 状态变化是异步的，必须在 stateChange 的 'initialized' 事件中调用
      // prepare() 已移至 stateChange 的 'initialized' 分支
      // loop 设置已移至 'prepared' 分支
    } catch (err) {
      let error = err as Error;
      console.error(`[BGM_DEBUG] 播放BGM失败: ${error.message}`, error);
    }
  }

  /**
   * 播放音效
   */
  async playSound(soundType: 'click' | 'flag' | 'win' | 'lose'): Promise<void> {
    if (!this.soundEnabled || !this.context) {
      console.log('[SOUND_DEBUG] Sound disabled or no context');
      return;
    }

    try {
      console.log(`[SOUND_DEBUG] 开始播放音效: ${soundType}`);
      
      // 停止之前的音效
      if (this.soundPlayer) {
        try {
          await this.soundPlayer.stop();
          await this.soundPlayer.release();
          console.log('[SOUND_DEBUG] 音效播放器已释放');
        } catch (e) {
          console.log('[SOUND_DEBUG] Error stopping sound:', e);
        }
        this.soundPlayer = null;
        this.currentSoundFd = null;
      }

      this.soundPlayer = await media.createAVPlayer();
      console.log('[SOUND_DEBUG] AVPlayer创建成功');
      
      // ✅ 设置初始音量（使用setVolume方法）
      this.soundPlayer.setVolume(this.soundVolume);
      console.log(`[SOUND_DEBUG] 初始音量已设置: ${this.soundVolume}`);
      
      // 根据音效类型设置资源路径
      let soundPath: string = '';
      switch (soundType) {
        case 'click':
          soundPath = 'music/Sound_Effects/羊叫声.mp3';
          break;
        case 'flag':
          soundPath = 'music/Sound_Effects/插旗声.mp3';
          break;
        case 'win':
          soundPath = 'music/Sound_Effects/欢呼声.mp3';
          break;
        case 'lose':
          soundPath = 'music/Sound_Effects/游戏失败.mp3';
          break;
      }
      
      console.log(`[SOUND_DEBUG] 音效类型: ${soundType}`);
      console.log(`[SOUND_DEBUG] 资源路径: ${soundPath}`);
      
      // 设置状态变化监听器（必须在设置fdSrc之前）
      this.soundPlayer.on('stateChange', async (state: string) => {
        console.log(`[SOUND_STATE] ${soundType} 状态: ${state}`);
        
        if (state === 'error') {
          console.error(`[SOUND_STATE] 错误状态，当前state: ${this.soundPlayer?.state}`);
        }
        
        // ✅ 在 initialized 状态时调用 prepare
        if (state === 'initialized') {
          console.log(`[SOUND_STATE] ${soundType} 已初始化，开始准备播放`);
          try {
            await this.soundPlayer?.prepare();
            console.log(`[SOUND_STATE] ${soundType} prepare()已调用`);
          } catch (e) {
            console.error(`[SOUND_STATE] ${soundType} prepare失败:`, e);
          }
        }
        
        if (state === 'prepared') {
          console.log(`[SOUND_STATE] 准备完成，开始播放 ${soundType}`);
          try {
            // ✅ 关键修复：在 prepared 状态再次设置音量，确保生效
            if (this.soundPlayer) {
              this.soundPlayer.setVolume(this.soundVolume);
              console.log(`[SOUND_STATE] 音量已在prepared状态设置: ${this.soundVolume}`);
            }
            await this.soundPlayer?.play();
            console.log(`[SOUND_STATE] ${soundType} 播放指令已发送`);
          } catch (e) {
            console.error(`[SOUND_STATE] ${soundType} 播放失败:`, e);
          }
        }
        
        if (state === 'playing') {
          console.log(`[SOUND_STATE] ${soundType} 正在播放中 🔊`);
        }
      });

      this.soundPlayer.on('error', (err: Error) => {
        console.error(`[SOUND_STATE] ${soundType} 播放错误:`, err.message);
      });
      
      // 使用文件描述符方式加载资源
      const fd = await this.context.resourceManager.getRawFd(soundPath);
      console.log(`[SOUND_DEBUG] 文件描述符: fd=${fd.fd}, offset=${fd.offset}, length=${fd.length}`);
      console.log(`[SOUND_DEBUG] fd有效性: ${fd.fd >= 0}`);
      
      if (fd.fd < 0) {
        console.error('[SOUND_DEBUG] 文件描述符无效');
        return;
      }
      
      // 保存fd引用以便后续关闭
      this.currentSoundFd = fd;
      
      this.soundPlayer.fdSrc = {
        fd: fd.fd,
        offset: fd.offset,
        length: fd.length
      };
      console.log('[SOUND_DEBUG] fdSrc已设置，触发状态变化到initialized...');
      console.log('[SOUND_DEBUG] 等待状态机自动处理 initialized → prepared → playing');
      // ❌ 不要在这里调用 prepare()！由 stateChange 监听器自动处理
    } catch (err) {
      let error = err as Error;
      console.error(`[SOUND_DEBUG] 播放音效失败: ${error.message}`, error);
    }
  }

  /**
   * 停止BGM
   */
  async stopBGM(): Promise<void> {
    if (this.bgmPlayer) {
      try {
        const state = this.bgmPlayer.state;
        console.log(`Stopping BGM, current state: ${state}`);
        
        if (state === 'playing' || state === 'paused') {
          await this.bgmPlayer.stop();
        }
        
        await this.bgmPlayer.release();
        this.bgmPlayer = null;
        this.currentBGMPath = ''; // 清除当前BGM路径
        console.log('BGM stopped and released');
      } catch (err) {
        console.error(`停止BGM失败: ${err}`);
      }
    }
  }

  /**
   * 设置BGM音量
   */
  setBGMVolume(volume: number): void {
    // 限制音量范围在 0.0-1.0 之间
    this.bgmVolume = Math.max(0, Math.min(1, volume));
    console.log(`[VOLUME] 设置BGM音量: ${this.bgmVolume}`);
    
    // ✅ 实际应用到AVPlayer（使用setVolume方法）
    if (this.bgmPlayer) {
      try {
        this.bgmPlayer.setVolume(this.bgmVolume);
        console.log(`[VOLUME] BGM音量已应用到播放器: ${this.bgmVolume}`);
      } catch (err) {
        console.error(`[VOLUME] 设置BGM音量失败:`, err);
      }
    } else {
      console.warn(`[VOLUME] BGM播放器未初始化，音量将在下次播放时应用`);
    }
    
    // ✅ 保存到持久化存储
    this.saveVolumeSettings();
  }

  /**
   * 设置音效音量
   */
  setSoundVolume(volume: number): void {
    // 限制音量范围在 0.0-1.0 之间
    this.soundVolume = Math.max(0, Math.min(1, volume));
    console.log(`[VOLUME] 设置音效音量: ${this.soundVolume}`);
    
    // ✅ 实际应用到AVPlayer（使用setVolume方法）
    // 音效播放器在每次播放时创建，所以这里保存值即可，创建时会应用
    if (this.soundPlayer) {
      try {
        this.soundPlayer.setVolume(this.soundVolume);
        console.log(`[VOLUME] 音效音量已应用到播放器: ${this.soundVolume}`);
      } catch (err) {
        console.error(`[VOLUME] 设置音效音量失败:`, err);
      }
    }
    
    // ✅ 保存到持久化存储
    this.saveVolumeSettings();
  }

  /**
   * 启用/禁用BGM
   */
  setBGMEnabled(enabled: boolean): void {
    this.bgmEnabled = enabled;
    if (!enabled) {
      // 调用异步停止BGM方法（错误已在方法内部处理）
      this.stopBGMAsync();
    }
  }

  /**
   * 异步停止BGM（用于避免Promise.catch的unknown类型问题）
   */
  private async stopBGMAsync(): Promise<void> {
    try {
      await this.stopBGM();
    } catch (error) {
      console.error('停止BGM失败:', error);
    }
  }

  /**
   * 启用/禁用音效
   */
  setSoundEnabled(enabled: boolean): void {
    this.soundEnabled = enabled;
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    try {
      console.log('[RELEASE] 释放音频资源');
      
      // 清空BGM fd引用
      this.currentBGMFd = null;
      
      await this.stopBGM();
      
      if (this.soundPlayer) {
        try {
          const state = this.soundPlayer.state;
          console.log(`[RELEASE] 停止音效, 当前状态: ${state}`);
          
          if (state === 'playing' || state === 'paused') {
            await this.soundPlayer.stop();
          }
          
          // 清空音效fd引用
          this.currentSoundFd = null;
          
          await this.soundPlayer.release();
          this.soundPlayer = null;
          console.log('[RELEASE] 音效播放器已释放');
        } catch (e) {
          console.error('[RELEASE] 释放音效播放器失败:', e);
        }
      }
      
      console.log('[RELEASE] 音频资源释放完成');
    } catch (err) {
      console.error(`[RELEASE] 释放音频资源失败: ${err}`);
    }
  }
  
  /**
   * 获取BGM启用状态
   */
  isBGMEnabled(): boolean {
    return this.bgmEnabled;
  }
  
  /**
   * 获取音效启用状态
   */
  isSoundEnabled(): boolean {
    return this.soundEnabled;
  }
}

export const audioManager = AudioManager.getInstance();
