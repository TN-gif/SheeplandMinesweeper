/**
 * 音频管理器
 * 负责播放背景音乐和音效
 */
import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';

export class AudioManager {
  private static instance: AudioManager;
  private bgmPlayer: media.AVPlayer | null = null;
  private soundPlayer: media.AVPlayer | null = null;
  private bgmVolume: number = 0.5;
  private soundVolume: number = 0.7;
  private bgmEnabled: boolean = true;
  private soundEnabled: boolean = true;
  private context?: common.UIAbilityContext;

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
  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  /**
   * 播放背景音乐
   */
  async playBGM(resourcePath: string): Promise<void> {
    if (!this.bgmEnabled || !this.context) {
      console.log('BGM disabled or no context');
      return;
    }

    try {
      // 停止当前BGM
      if (this.bgmPlayer) {
        await this.bgmPlayer.stop();
        await this.bgmPlayer.release();
        this.bgmPlayer = null;
      }

      // 创建新的播放器
      this.bgmPlayer = await media.createAVPlayer();
      
      // 使用文件描述符方式加载资源
      const fd = await this.context.resourceManager.getRawFd(resourcePath);
      this.bgmPlayer.fdSrc = {
        fd: fd.fd,
        offset: fd.offset,
        length: fd.length
      };
      this.bgmPlayer.loop = true;
      
      this.bgmPlayer.on('stateChange', (state: string) => {
        if (state === 'prepared') {
          this.bgmPlayer?.play();
        }
      });

      this.bgmPlayer.on('error', (err: Error) => {
        console.error('BGM播放错误:', err.message);
      });

      await this.bgmPlayer.prepare();
    } catch (err) {
      let error = err as Error;
      console.error(`播放BGM失败: ${error.message}`);
    }
  }

  /**
   * 播放音效
   */
  async playSound(soundType: 'click' | 'flag' | 'win' | 'lose'): Promise<void> {
    if (!this.soundEnabled || !this.context) return;

    try {
      if (this.soundPlayer) {
        await this.soundPlayer.stop();
        await this.soundPlayer.release();
        this.soundPlayer = null;
      }

      this.soundPlayer = await media.createAVPlayer();
      
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
          soundPath = 'music/Sound_Effects/羊叫声.mp3';
          break;
      }
      
      // 使用文件描述符方式加载资源
      const fd = await this.context.resourceManager.getRawFd(soundPath);
      this.soundPlayer.fdSrc = {
        fd: fd.fd,
        offset: fd.offset,
        length: fd.length
      };
      
      this.soundPlayer.on('stateChange', (state: string) => {
        if (state === 'prepared') {
          this.soundPlayer?.play();
        }
      });

      this.soundPlayer.on('error', (err: Error) => {
        console.error('音效播放错误:', err.message);
      });

      await this.soundPlayer.prepare();
    } catch (err) {
      let error = err as Error;
      console.error(`播放音效失败: ${error.message}`);
    }
  }

  /**
   * 停止BGM
   */
  async stopBGM(): Promise<void> {
    if (this.bgmPlayer) {
      try {
        await this.bgmPlayer.stop();
        await this.bgmPlayer.release();
        this.bgmPlayer = null;
      } catch (err) {
        console.error(`停止BGM失败: ${err}`);
      }
    }
  }

  /**
   * 设置BGM音量
   * 注意: AVPlayer 不直接支持音量控制，需要通过系统音量管理
   */
  setBGMVolume(volume: number): void {
    this.bgmVolume = Math.max(0, Math.min(1, volume));
    // AVPlayer 不支持直接设置 volume 属性
    // 实际音量控制需要通过系统音量或音频管理器
  }

  /**
   * 设置音效音量
   */
  setSoundVolume(volume: number): void {
    this.soundVolume = Math.max(0, Math.min(1, volume));
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
      await this.stopBGM();
      if (this.soundPlayer) {
        await this.soundPlayer.stop();
        await this.soundPlayer.release();
        this.soundPlayer = null;
      }
    } catch (err) {
      console.error(`释放音频资源失败: ${err}`);
    }
  }
}

export const audioManager = AudioManager.getInstance();
