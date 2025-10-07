import vibrator from '@ohos.vibrator';

export class HapticFeedbackUtils {
  private static isEnabled: boolean = true;

  public static setEnabled(enabled: boolean): void {
    HapticFeedbackUtils.isEnabled = enabled;
  }

  public static vibrate(effect: 'heavy' | 'light' | 'success' | 'failure' | 'click' | 'flag'): void {
    if (!HapticFeedbackUtils.isEnabled) return;

    try {
      if (effect === 'success') {
        // 自定义成功震动模式：短震动
        HapticFeedbackUtils.playCustomPattern([100]);
        return;
      } else if (effect === 'failure') {
        // 自定义失败震动模式：长震动
        HapticFeedbackUtils.playCustomPattern([300]);
        return;
      }

      // 使用简单的时间震动模式
      let duration: number = 10;
      switch (effect) {
        case 'heavy':
          duration = 50;
          break;
        case 'light':
          duration = 10;
          break;
        case 'click':
          duration = 15;
          break;
        case 'flag':
          duration = 20;
          break;
        default:
          duration = 15;
      }
      
      vibrator.startVibration(
        {
          type: 'time',
          duration: duration
        },
        {
          usage: 'touch'
        }
      );
    } catch (error) {
      let err = error as Error;
      console.error('Vibration failed:', err.message);
    }
  }

  private static playCustomPattern(durations: number[]): void {
    try {
      durations.forEach((duration: number) => {
        vibrator.startVibration(
          {
            type: 'time',
            duration: duration
          },
          {
            usage: 'touch'
          }
        );
      });
    } catch (error) {
      let err = error as Error;
      console.error('Custom vibration failed:', err.message);
    }
  }
}
