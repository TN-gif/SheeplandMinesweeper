import { Achievement } from '../model/Achievement';
import { achievementService } from '../services/AchievementService';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';
import { FontManager } from '../utils/FontManager';

@Component
export struct AchievementsScreen {
  @State achievements: Achievement[] = [];
  @State currentNavTab: string = 'achievements';
  @ObjectLink provider: ThemeProvider;
  onBack: () => void = () => {};
  onNavigate: (tab: string) => void = () => {};

  aboutToAppear() {
    this.achievements = achievementService.getAchievements();
  }

  build() {
    Stack() {
      // 背景图片
      Image($rawfile('images/background/成就背景.jpg'))
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 成就1
      this.AchievementCard(0, '小羊诞生啦！', '首次通关游戏', 35, 68);

      // 成就2
      this.AchievementCard(1, '小小勇士', '累计通关10次', 35, 215);

      // 成就3
      this.AchievementCard(2, '羊村大守护', '累计通关100次', 35, 362);

      // 成就4
      this.AchievementCard(3, '焦炭小羊', '累计被灰太狼发现10次', 35, 509);

      // 底部导航栏
      this.BottomNavBar();
    }
    .width(360)
    .height(792);
  }

  // 成就卡片Builder
  @Builder AchievementCard(index: number, title: string, description: string, x: number, y: number) {
    // 在@Builder中不能使用const声明，需要直接访问数组
    if (index < this.achievements.length) {
      Stack() {
        // Dialog/BG 白色半透明背景
        Column()
          .width(291)
          .height(115)
          .backgroundColor('rgba(255, 255, 255, 0.85)')
          .borderRadius(20);

        // 文字区域
        Stack() {
          // 标题
          Text(title)
            .width(243)
            .height(42)
            .fontSize(36)
            .fontWeight(400)
            .lineHeight(40)
            .fontColor(this.achievements[index].unlocked ? Color.Black : '#888888')
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Start)
            .position({ x: 0, y: 0 });

          // 描述
          Text(description)
            .width(243)
            .height(23)
            .fontSize(18)
            .fontWeight(400)
            .lineHeight(20)
            .fontColor(this.achievements[index].unlocked ? Color.Black : '#999999')
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Start)
            .position({ x: 0, y: 52 });
        }
        .width(243)
        .height(75)
        .position({ x: 24, y: 20 });
      }
      .width(291)
      .height(115)
      .position({ x: x, y: y });
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
        .height(19)
        .fontSize(18)
        .fontWeight(400)
        .lineHeight(20)
        .fontColor(tab === 'achievements' ? this.provider.currentTheme.colors.primary : Color.Black)
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
