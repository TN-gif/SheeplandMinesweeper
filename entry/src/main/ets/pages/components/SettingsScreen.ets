/**
 * 设置界面
 * 允许用户调整音效设置
 */
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';
import { audioManager } from '../services/AudioManager';
import { FontManager } from '../utils/FontManager';

@Component
export struct SettingsScreen {
  @ObjectLink provider: ThemeProvider;
  @State bgmVolume: number = 0.27;
  @State soundVolume: number = 0.27;
  @State currentNavTab: string = 'settings';
  onBack: () => void = () => {};
  onNavigate: (tab: string) => void = () => {};
  onSelectCharacter: () => void = () => {};

  aboutToAppear(): void {
    // ✅ 从 audioManager 读取实际音量值，确保显示同步
    this.bgmVolume = audioManager.getBGMVolume();
    this.soundVolume = audioManager.getSoundVolume();
    console.log(`[SETTINGS] 加载音量设置: BGM=${this.bgmVolume}, Sound=${this.soundVolume}`);
  }

  private async playBGMSafely(): Promise<void> {
    try {
      await audioManager.playBGM(this.provider.currentTheme.audio.bgm);
    } catch (error) {
      console.error('Failed to play BGM:', error);
    }
  }

  build() {
    Stack() {
      // 背景图片
      Image($rawfile('images/background/设置页面.jpg'))
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 控制音量区域
      Stack() {
        // 背景音乐
        Stack() {
          Text('背景音乐')
            .width(303)
            .height(47)
            .fontSize(40)
            .fontWeight(400)
            .lineHeight(44)
            .fontColor('rgba(0, 0, 0, 0.9)')
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Start)
            .position({ x: 0, y: 0 });

          // 背景音乐音量条（直接内联）
          Stack() {
            // 背景条
            Column()
              .width(303)
              .height(36)
              .backgroundColor('rgba(190, 211, 238, 1)')
              .borderRadius(4);

            // 边框
            Column()
              .width(307)
              .height(40)
              .backgroundColor(Color.Transparent)
              .borderRadius(6)
              .border({ width: 2, color: Color.Black })
              .position({ x: -2, y: -2 });

            // 进度条（响应式宽度）
            Column()
              .width(303 * this.bgmVolume)
              .height(36)
              .backgroundColor('rgba(100, 150, 200, 1)')
              .borderRadius(4)
              .position({ x: 0, y: 0 });

            // 百分比文字
            Text(`${Math.round(this.bgmVolume * 100)}%`)
              .width(303)
              .height(36)
              .fontSize(20)
              .fontWeight(400)
              .lineHeight(22)
              .fontColor(Color.Black)
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
              .textAlign(TextAlign.Center)
              .padding({ top: 7 });

            // Slider（放在最上层）
            Slider({
              value: this.bgmVolume * 100,
              min: 0,
              max: 100,
              step: 1,
              style: SliderStyle.OutSet
            })
              .width(303)
              .height(36)
              .trackColor(Color.Transparent)
              .selectedColor(Color.Transparent)
              .blockColor('rgba(100, 150, 200, 0.5)') // 半透明滑块，便于定位
              .showTips(false)
              .onChange((sliderValue: number, mode: SliderChangeMode) => {
                console.log(`[VOLUME_BGM] 音量变化: ${sliderValue}%, 模式: ${mode}`);
                this.bgmVolume = sliderValue / 100;
                audioManager.setBGMVolume(this.bgmVolume);
              });
          }
          .width(303)
          .height(36)
          .position({ x: 0, y: 56 });
        }
        .width(303)
        .height(92)
        .position({ x: 0, y: 0 });

        // 游戏音效
        Stack() {
          Text('游戏音效')
            .width(303)
            .height(47)
            .fontSize(40)
            .fontWeight(400)
            .lineHeight(44)
            .fontColor('rgba(0, 0, 0, 0.9)')
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Start)
            .position({ x: 0, y: 0 });

          // 游戏音效音量条（直接内联）
          Stack() {
            // 背景条
            Column()
              .width(303)
              .height(36)
              .backgroundColor('rgba(190, 211, 238, 1)')
              .borderRadius(4);

            // 边框
            Column()
              .width(307)
              .height(40)
              .backgroundColor(Color.Transparent)
              .borderRadius(6)
              .border({ width: 2, color: Color.Black })
              .position({ x: -2, y: -2 });

            // 进度条（响应式宽度）
            Column()
              .width(303 * this.soundVolume)
              .height(36)
              .backgroundColor('rgba(100, 150, 200, 1)')
              .borderRadius(4)
              .position({ x: 0, y: 0 });

            // 百分比文字
            Text(`${Math.round(this.soundVolume * 100)}%`)
              .width(303)
              .height(36)
              .fontSize(20)
              .fontWeight(400)
              .lineHeight(22)
              .fontColor(Color.Black)
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
              .textAlign(TextAlign.Center)
              .padding({ top: 7 });

            // Slider（放在最上层）
            Slider({
              value: this.soundVolume * 100,
              min: 0,
              max: 100,
              step: 1,
              style: SliderStyle.OutSet
            })
              .width(303)
              .height(36)
              .trackColor(Color.Transparent)
              .selectedColor(Color.Transparent)
              .blockColor('rgba(100, 150, 200, 0.5)') // 半透明滑块，便于定位
              .showTips(false)
              .onChange((sliderValue: number, mode: SliderChangeMode) => {
                console.log(`[VOLUME_SOUND] 音量变化: ${sliderValue}%, 模式: ${mode}`);
                this.soundVolume = sliderValue / 100;
                audioManager.setSoundVolume(this.soundVolume);
              });
          }
          .width(303)
          .height(36)
          .position({ x: 0, y: 56 });
        }
        .width(303)
        .height(92)
        .position({ x: 0, y: 115 });
      }
      .width(303)
      .height(207)
      .position({ x: 29, y: 57 });

      // 选择小羊按钮
      Stack() {
        // 白色背景
        Column()
          .width(190)
          .height(58)
          .backgroundColor('rgba(255, 255, 255, 0.9)')
          .borderRadius(29);

        // 黑色边框矩形
        Column()
          .width(198)
          .height(66)
          .backgroundColor(Color.Transparent)
          .borderRadius(33)
          .border({ width: 2, color: Color.Black })
          .position({ x: -4, y: -4 });

        // 按钮文本
        Text('选择小羊')
          .width(124)
          .height(34)
          .fontSize(31)
          .fontWeight(400)
          .lineHeight(34)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Center)
          .position({ x: 33, y: 12 });
      }
      .width(190)
      .height(58)
      .position({ x: 85, y: 627 })
      .onClick(this.onSelectCharacter);

      // 底部导航栏
      this.BottomNavBar();
    }
    .width(360)
    .height(792);
  }

  // 注：原VolumeBar Builder已废弃，改为直接内联以支持响应式状态更新

  // 底部导航栏
  @Builder BottomNavBar() {
    Stack() {
      // 导航容器
      Stack() {
        // 成就标签
        this.NavTab('成就', 'images/icon/成就.png', 0, 0, 'achievements');

        // 游戏标签
        this.NavTab('游戏', 'images/icon/游戏.png', 119, 0, 'game');

        // 设置标签
        this.NavTab('设置', 'images/icon/设置.png', 238, 0, 'settings');
      }
      .width(350)
      .height(47)
      .position({ x: 5, y: 0 });
    }
    .width(360)
    .height(47)
    .position({ x: 0, y: 717 });
  }

  // 导航标签Builder
  @Builder NavTab(text: string, icon: string, x: number, y: number, tab: string) {
    Stack() {
      // 图标
      Image($rawfile(icon))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .position({ x: 44, y: 0 });

      // 文本
      Text(text)
        .width(112)
        .height(16)
        .fontSize(18)
        .fontWeight(400)
        .lineHeight(20)
        .fontColor(tab === 'settings' ? '#3E6796' : Color.Black)
        .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
        .textAlign(TextAlign.Center)
        .position({ x: 0, y: 30 });
    }
    .width(112)
    .height(46)
    .position({ x: x, y: y })
    .onClick(() => {
      this.currentNavTab = tab;
      this.onNavigate(tab);
    });
  }
}
