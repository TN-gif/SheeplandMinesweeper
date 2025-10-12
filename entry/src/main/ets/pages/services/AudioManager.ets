/**
 * 音频管理器（单例模式）
 * 
 * 统一管理应用中的所有音频播放，包括：
 * - 背景音乐（BGM）的播放、切换和循环
 * - 音效（点击、插旗、胜利、失败）的播放
 * - 音量控制和持久化存储
 * - 资源的正确加载和释放
 * 
 * 设计要点：
 * - 使用单例模式确保全局唯一的音频管理器
 * - BGM支持无缝切换和循环播放
 * - 音量设置会自动保存到本地，下次启动时恢复
 * - 正确处理AVPlayer状态机，避免状态错误
 */
import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import audio from '@ohos.multimedia.audio';
import resourceManager from '@ohos.resourceManager';
import preferences from '@ohos.data.preferences';

export class AudioManager {
  private static instance: AudioManager;
  
  /** BGM播放器实例 */
  private bgmPlayer: media.AVPlayer | null = null;
  
  /** 音效播放器实例 */
  private soundPlayer: media.AVPlayer | null = null;
  
  /** BGM音量（0.0-1.0），默认27% */
  private bgmVolume: number = 0.27;
  
  /** 音效音量（0.0-1.0），默认27% */
  private soundVolume: number = 0.27;
  
  /** BGM是否启用 */
  private bgmEnabled: boolean = true;
  
  /** 音效是否启用 */
  private soundEnabled: boolean = true;
  
  /** 应用上下文，用于访问资源管理器 */
  private context?: common.UIAbilityContext;
  
  /** 当前BGM的文件描述符引用 */
  private currentBGMFd: resourceManager.RawFileDescriptor | null = null;
  
  /** 当前音效的文件描述符引用 */
  private currentSoundFd: resourceManager.RawFileDescriptor | null = null;
  
  /** 当前正在播放的BGM路径，用于避免重复播放 */
  private currentBGMPath: string = '';
  
  /** 数据持久化存储实例，用于保存音量设置 */
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() {}

  /**
   * 获取AudioManager的单例实例
   * 
   * @returns {AudioManager} 音频管理器实例
   */
  static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }

  /**
   * 设置应用上下文并初始化音频系统
   * 
   * 必须在使用音频功能前调用此方法。
   * 会自动加载上次保存的音量设置。
   * 
   * @param {common.UIAbilityContext} context - 应用上下文
   * @returns {Promise<void>} 初始化完成的Promise
   */
  async setContext(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    // 初始化数据持久化存储，加载上次保存的音量设置
    await this.initPreferences();
  }

  /**
   * 初始化数据持久化存储
   * 
   * 创建preferences实例并加载保存的音量设置。
   * 如果是首次启动，会使用默认音量值。
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
   * 从本地存储加载音量设置
   * 
   * 读取上次保存的BGM和音效音量值。
   * 如果没有保存的值，使用默认值0.27。
   * 音量值会被限制在0.0-1.0范围内。
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
   * 保存音量设置到本地存储
   * 
   * 将当前的BGM和音效音量持久化到磁盘。
   * 确保用户的音量偏好在应用重启后保持。
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
   * 检测音频设备可用性
   * 
   * 简化实现，仅输出日志。
   * 原因：避免使用可能不稳定的设备检测API，依赖系统自动处理。
   */
  checkAudioDevices(): void {
    console.log('[AUDIO_DEBUG] 音频系统初始化中...');
  }

  /**
   * 播放背景音乐
   * 
   * 智能切换BGM，避免重复播放相同音乐。
   * 支持循环播放和音量控制。
   * 
   * 技术要点：
   * - 使用AVPlayer状态机正确处理异步状态变化
   * - 在initialized状态调用prepare()
   * - 在prepared状态设置循环和开始播放
   * - 使用文件描述符方式加载rawfile资源
   * 
   * @param {string} resourcePath - 音乐文件在rawfile中的相对路径
   * @returns {Promise<void>} 播放操作完成的Promise
   * 
   * @example
   * ```
   * await audioManager.playBGM('music/Background/主页面背景音乐.mp3');
   * ```
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
      
      // 注意：不要在这里调用 prepare()
      // 原因：AVPlayer状态变化是异步的，必须在stateChange的'initialized'事件中调用
      // prepare()已移至stateChange的'initialized'分支
      // loop设置已移至'prepared'分支
    } catch (err) {
      let error = err as Error;
      console.error(`[BGM_DEBUG] 播放BGM失败: ${error.message}`, error);
    }
  }

  /**
   * 播放音效
   * 
   * 播放短音效（点击、插旗、胜利、失败）。
   * 每次播放会创建新的播放器实例，支持快速连续播放。
   * 
   * @param {string} soundType - 音效类型：'click' | 'flag' | 'win' | 'lose'
   * @returns {Promise<void>} 播放操作完成的Promise
   * 
   * @example
   * ```
   * await audioManager.playSound('click'); // 播放点击音效
   * ```
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
      // 注意：不要在这里调用prepare()，由stateChange监听器自动处理
    } catch (err) {
      let error = err as Error;
      console.error(`[SOUND_DEBUG] 播放音效失败: ${error.message}`, error);
    }
  }

  /**
   * 停止背景音乐
   * 
   * 安全地停止并释放BGM播放器。
   * 会根据播放器状态选择合适的停止方式。
   * 
   * @returns {Promise<void>} 停止操作完成的Promise
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
   * 
   * 动态调整背景音乐音量，立即生效并保存到本地。
   * 音量值会被限制在0.0-1.0范围内。
   * 
   * @param {number} volume - 音量值（0.0-1.0）
   */
  setBGMVolume(volume: number): void {
    // 限制音量范围在0.0-1.0之间
    this.bgmVolume = Math.max(0, Math.min(1, volume));
    console.log(`[VOLUME] 设置BGM音量: ${this.bgmVolume}`);
    
    // 如果BGM正在播放，立即应用新音量
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
    
    // 保存到本地存储，下次启动时恢复
    this.saveVolumeSettings();
  }

  /**
   * 设置音效音量
   * 
   * 动态调整音效音量，立即生效并保存到本地。
   * 音量值会被限制在0.0-1.0范围内。
   * 
   * @param {number} volume - 音量值（0.0-1.0）
   */
  setSoundVolume(volume: number): void {
    // 限制音量范围在0.0-1.0之间
    this.soundVolume = Math.max(0, Math.min(1, volume));
    console.log(`[VOLUME] 设置音效音量: ${this.soundVolume}`);
    
    // 音效播放器在每次播放时创建，所以这里保存值即可，创建时会应用
    if (this.soundPlayer) {
      try {
        this.soundPlayer.setVolume(this.soundVolume);
        console.log(`[VOLUME] 音效音量已应用到播放器: ${this.soundVolume}`);
      } catch (err) {
        console.error(`[VOLUME] 设置音效音量失败:`, err);
      }
    }
    
    // 保存到本地存储，下次启动时恢复
    this.saveVolumeSettings();
  }

  /**
   * 启用或禁用BGM播放
   * 
   * @param {boolean} enabled - true=启用，false=禁用
   */
  setBGMEnabled(enabled: boolean): void {
    this.bgmEnabled = enabled;
    if (!enabled) {
      // 禁用时立即停止BGM播放
      this.stopBGMAsync();
    }
  }

  /**
   * 异步停止BGM的包装方法
   * 
   * 用于在同步方法中安全调用异步停止操作。
   */
  private async stopBGMAsync(): Promise<void> {
    try {
      await this.stopBGM();
    } catch (error) {
      console.error('停止BGM失败:', error);
    }
  }

  /**
   * 启用或禁用音效播放
   * 
   * @param {boolean} enabled - true=启用，false=禁用
   */
  setSoundEnabled(enabled: boolean): void {
    this.soundEnabled = enabled;
  }

  /**
   * 释放所有音频资源
   * 
   * 停止并释放BGM和音效播放器。
   * 应在应用退出时调用以避免资源泄漏。
   * 
   * @returns {Promise<void>} 释放操作完成的Promise
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
