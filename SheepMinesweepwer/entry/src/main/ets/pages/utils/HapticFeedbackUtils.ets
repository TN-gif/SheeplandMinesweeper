import vibrator from '@ohos.vibrator';

export class HapticFeedbackUtils {
  public static vibrate(effect: 'heavy' | 'light' | 'success' | 'failure') {
    let effectId: string;
    switch (effect) {
      case 'heavy':
        effectId = vibrator.VibrationEffect.EFFECT_HEAVY_CLICK;
        break;
      case 'light':
        effectId = vibrator.VibrationEffect.EFFECT_LIGHT_CLICK;
        break;
      case 'success':
        effectId = 'haptic.success'; // Placeholder for a success effect
        break;
      case 'failure':
        effectId = 'haptic.failure'; // Placeholder for a failure effect
        break;
    }
    try {
      vibrator.startVibration({
        type: 'preset',
        effectId: effectId,
        count: 1
      }, (err) => {
        if (err) {
          console.error('Failed to vibrate:', err);
        }
      });
    } catch (e) {
      console.error('Vibration not supported on this device.');
    }
  }
}
