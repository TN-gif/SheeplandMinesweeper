import { adventureService } from '../services/AdventureService';
import { Level } from '../model/Level';
import { AdventureStage } from '../services/AdventureService';
import common from '@ohos.app.ability.common';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';
import { FontManager } from '../utils/FontManager';

@Component
export struct AdventureMapScreen {
  @State stages: AdventureStage[] = [];
  @State currentStageIndex: number = 0;
  @State currentNavTab: string = 'game';
  @ObjectLink provider: ThemeProvider;
  onSelectLevel: (level: Level) => void = () => {};
  onBack: () => void = () => {};
  onNavigate: (tab: string) => void = () => {};
  context?: common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    this.stages = adventureService.getStages();
    this.currentStageIndex = adventureService.getCurrentStageIndex();
  }

  // 辅助方法：获取关卡名称
  getStageName(stage: AdventureStage): string {
    const level = adventureService.getLevelForStage(stage);
    return level ? level.name : '未知关卡';
  }

  build() {
    Stack() {
      // 背景图片 - 随主题变化
      Image(this.provider.currentTheme.assets.background)
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 返回按钮
      Stack() {
        // 返回组合
        Stack() {
          Column()
            .width(32)
            .height(32)
            .backgroundColor('rgba(255, 255, 255, 0.9)')
            .borderRadius(16);

          Image($rawfile('images/icon/返回.png'))
            .width(17)
            .height(18)
            .objectFit(ImageFit.Contain)
            .position({ x: 8, y: 7 });
        }
        .width(32)
        .height(32)
        .position({ x: 0, y: 0 });

        Text('返回菜单')
          .width(99)
          .height(32)
          .fontSize(24)
          .fontWeight(400)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 42, y: 0 });
      }
      .width(141)
      .height(32)
      .position({ x: 18, y: 42 })
      .onClick(this.onBack);

      // 冒险模式标题
      Text('冒险模式')
        .width(306)
        .height(75)
        .fontSize(75)
        .fontWeight(400)
        .lineHeight(83)
        .fontColor(Color.Black)
        .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
        .textAlign(TextAlign.Start)
        .position({ x: 27, y: 92 });

      // 组合1 - 关卡区域
      Stack() {
        // 动态渲染关卡列表（直接在参数中计算位置）
        ForEach(this.stages, (stage: AdventureStage, index: number) => {
          // 直接调用，位置通过三元运算符计算
          this.StageCard(
            index,
            `${index + 1}.${this.getStageName(stage)}`,
            index === 0 ? 0 : (index === 1 ? 94 : 17),
            index === 0 ? 0 : (index === 1 ? 129 : 257)
          );
        });

        // 更多按钮（永久灰色不可点击）
        Stack() {
          // Dialog/BG - 灰色背景
          Column()
            .width(97)
            .height(65)
            .backgroundColor('rgba(200, 200, 200, 0.6)')
            .borderRadius(15);

          Text('更多')
            .width(74)
            .height(40)
            .fontSize(36)
            .fontWeight(400)
            .lineHeight(40)
            .fontColor('#888888')
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Center)
            .position({ x: 12, y: 13 });
        }
        .width(97)
        .height(65)
        .position({ x: 176, y: 369 });
      }
      .width(318)
      .height(434)
      .position({ x: 21, y: 201 });

      // 底部导航栏
      this.BottomNavBar();
    }
    .width(360)
    .height(792);
  }

  // 关卡卡片Builder
  @Builder StageCard(index: number, title: string, x: number, y: number) {
    // 在@Builder中不能使用const声明，需要直接计算
    if (index < this.stages.length) {
      Stack() {
        // Dialog/BG 白色半透明背景
        Column()
          .width(224)
          .height(65)
          .backgroundColor(index <= this.currentStageIndex ? 'rgba(255, 255, 255, 0.85)' : 'rgba(200, 200, 200, 0.6)')
          .borderRadius(15);

        Text(title)
          .width(224)
          .height(40)
          .fontSize(36)
          .fontWeight(400)
          .lineHeight(40)
          .fontColor(index <= this.currentStageIndex ? Color.Black : '#888888')
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Center)
          .position({ x: 0, y: 13 });
      }
      .width(224)
      .height(65)
      .position({ x: x, y: y })
      .onClick(() => {
        if (index <= this.currentStageIndex) {
          const level = adventureService.getLevelForStage(this.stages[index]);
          if (level) {
            this.onSelectLevel(level);
          }
        }
      });
    }
  }

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
      .width(360)
      .height(47)
      .position({ x: 0, y: 0 });
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
        .height(19)
        .fontSize(18)
        .fontWeight(400)
        .lineHeight(20)
        .fontColor(tab === 'game' ? this.provider.currentTheme.colors.primary : Color.Black)
        .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
        .textAlign(TextAlign.Center)
        .position({ x: 0, y: 28 });
    }
    .width(112)
    .height(47)
    .position({ x: x, y: y })
    .onClick(() => {
      this.currentNavTab = tab;
      this.onNavigate(tab);
    });
  }
}
