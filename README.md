# 小羊扫雷 (SheepMinesweeper)

基于 HarmonyOS Next 开发的扫雷游戏，以《喜羊羊与灰太狼》为主题，提供丰富的游戏模式和个性化体验。

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-API%2010+-blue)
![ArkTS](https://img.shields.io/badge/ArkTS-4.0+-green)
![License](https://img.shields.io/badge/license-MIT-orange)

---

## 🎮 功能特性

### 游戏模式
- **挑战模式**: 3个难度等级（初级、中级、高级）
- **自定义模式**: 自由定义棋盘大小和地雷数量
- **成就系统**: 丰富的成就徽章收集

### 主题系统
- 6个角色主题：喜羊羊、美羊羊、懒羊羊、沸羊羊、暖羊羊、慢羊羊
- 每个主题包含：
  - 独特的背景图片
  - 专属的配色方案

### 游戏功能
- **智能提示系统**: 放大镜道具显示安全区域
- **多种交互**: 支持单击、长按、双击操作
- **手势控制**: 棋盘缩放、拖拽功能
- **音频系统**: 背景音乐和游戏音效

### UI/UX
- **沉浸式体验**: 全屏显示，状态栏透明
- **自定义字体**: 使用牧瑶柔笔字体

---

## 🛠️ 技术栈

### 开发环境
- **IDE**: DevEco Studio (推荐最新版本)
- **HarmonyOS SDK**: API 10+
- **编程语言**: ArkTS 4.0+

### 核心技术
- **UI框架**: ArkUI (声明式UI)
- **状态管理**: @State, @Prop, @Link, @Observed, @ObjectLink
- **音频**: AVPlayer API
- **数据持久化**: Preferences API
- **资源管理**: ResourceManager API

### 架构模式
- **MVVM**: Model-View-ViewModel 架构
- **单例模式**: AudioManager, ThemeProvider
- **服务层**: AudioManager, AchievementService, LevelSelectService

---

## 📁 项目结构

```
SheepMinesweeper/
├── entry/                          # 主模块
│   ├── src/main/
│   │   ├── ets/                    # ArkTS 源代码
│   │   │   ├── entryability/       # 应用入口
│   │   │   │   └── EntryAbility.ets
│   │   │   └── pages/              # 页面和组件
│   │   │       ├── Index.ets       # 主页面
│   │   │       ├── components/     # UI组件
│   │   │       │   ├── CharacterSelectScreen.ets
│   │   │       │   ├── GameBoard.ets
│   │   │       │   ├── SettingsScreen.ets
│   │   │       │   └── ...
│   │   │       ├── model/          # 数据模型
│   │   │       │   ├── Level.ets
│   │   │       │   ├── Cell.ets
│   │   │       │   └── ...
│   │   │       ├── services/       # 服务层
│   │   │       │   ├── AudioManager.ets
│   │   │       │   ├── AchievementService.ets
│   │   │       │   └── ...
│   │   │       ├── viewModel/      # 视图模型
│   │   │       │   └── GameViewModel.ets
│   │   │       ├── theme/          # 主题系统
│   │   │       │   └── ThemeProvider.ets
│   │   │       └── utils/          # 工具类
│   │   │           ├── FontManager.ets
│   │   │           ├── Solver.ets
│   │   │           └── ...
│   │   ├── resources/              # 资源文件
│   │   │   └── rawfile/
│   │   │       ├── images/         # 图片资源
│   │   │       ├── music/          # 音频资源
│   │   │       ├── fonts/          # 字体资源
│   │   │       └── *.json          # 配置文件
│   │   └── module.json5            # 模块配置
│   └── build-profile.json5         # 构建配置
├── AppScope/                       # 应用级资源
│   └── resources/
├── docs/                           # 项目文档
│   ├── 音频系统开发与修复文档.md
│   ├── 代码修复与规范文档.md
│   ├── UI开发与修复综合文档.md
│   ├── Prototype.md                # 原型设计
│   ├── Draft.md                    # 初稿设计
│   └── design-summary.txt          # 设计总结
├── oh_modules/                     # 依赖模块
├── README.md                       # 本文件
└── build-profile.json5             # 项目构建配置
```

---

## 🚀 开始使用

### 前置要求

1. **安装 DevEco Studio**
   - 下载地址: [HarmonyOS 开发者官网](https://developer.huawei.com/consumer/cn/deveco-studio/)
   - 版本要求: 最新版本

2. **配置 HarmonyOS SDK**
   - API Level: 10 或更高
   - 包含 Preview 模拟器或真机

### 克隆项目

```bash
git clone https://github.com/yourusername/SheepMinesweeper.git
cd SheepMinesweeper/SheepMinesweepwer
```

### 导入项目

1. 打开 DevEco Studio
2. 选择 `File > Open`
3. 选择项目根目录
4. 等待依赖下载完成

### 运行项目

1. **使用模拟器**
   ```bash
   # 在 DevEco Studio 中
   1. 点击工具栏的 "Device Manager"
   2. 创建或启动一个模拟器
   3. 点击 "Run" 按钮运行应用
   ```

2. **使用真机**
   ```bash
   # 确保真机已开启开发者模式
   1. 通过 USB 连接设备
   2. 在设备列表中选择设备
   3. 点击 "Run" 按钮运行应用
   ```

### 构建 HAP 包

```bash
# 使用 hvigor 构建
hvigor clean
hvigor assembleHap

# 输出位置
# entry/build/default/outputs/default/entry-default-unsigned.hap
```

---

## 📚 文档目录

所有技术文档位于 `docs/` 目录：

### 核心文档
- **[音频系统开发与修复文档](docs/音频系统开发与修复文档.md)**: 完整的音频系统实现指南
  - AVPlayer 使用
  - 音量控制
  - 数据持久化
  - 常见问题解决

- **[代码修复与规范文档](docs/代码修复与规范文档.md)**: ArkTS 开发规范和问题修复
  - ArkTS 语法规范
  - 常见编译错误
  - API 升级指南
  - 最佳实践

- **[UI开发与修复综合文档](docs/UI开发与修复综合文档.md)**: UI/UX 开发完整指南
  - 页面开发
  - 字体系统
  - 屏幕适配
  - 沉浸式体验

### 设计文档
- **[Prototype.md](docs/Prototype.md)**: 项目原型设计
- **[Draft.md](docs/Draft.md)**: 初始设计草案
- **[design-summary.txt](docs/design-summary.txt)**: 设计总结

---

## 💡 开发规范

### 代码风格

#### ArkTS 规范
```typescript
// ✅ 正确：使用明确的类型
const volume: number = 0.5;
const name: string = '喜羊羊';

// ❌ 错误：不使用 any
const data: any = getData();
```

#### 异步处理
```typescript
// ✅ 正确：使用 async/await + try-catch
private async loadData(): Promise<void> {
  try {
    await service.fetchData();
  } catch (error) {
    let err = error as BusinessError;
    console.error('Error:', err.message);
  }
}

// ❌ 错误：使用 Promise.catch()
loadData().catch((err) => {
  console.error(err);  // err 是 unknown 类型
});
```

#### 对象创建
```typescript
// ✅ 正确：使用构造函数
const level = new Level('id', 'name', 9, 9, 10, true);

// ❌ 错误：使用对象字面量
const level: Level = {
  levelId: 'id',
  name: 'name'
};
```

### 命名规范

- **组件**: PascalCase (如 `GameBoard`)
- **方法**: camelCase (如 `playBGM`)
- **常量**: UPPER_SNAKE_CASE (如 `MAX_LEVEL`)
- **私有属性**: 以下划线或正常命名，加 `private` 修饰

### 注释规范

```typescript
/**
 * 播放背景音乐
 * @param resourcePath - 音频资源路径
 * @returns Promise<void>
 */
async playBGM(resourcePath: string): Promise<void> {
  // 实现代码
}
```

---

## 🎮 游戏玩法

### 基本操作
- **单击**: 翻开格子
- **长按**: 插旗/取消插旗
- **双击**: 快速翻开周围格子（当周围旗子数量等于数字时）

### 道具使用
- **放大镜**: 显示周围一定范围内的安全区域

### 成就系统
完成特定条件解锁成就徽章：
- 首次胜利
- 连胜记录
- 速度挑战
- 完美通关
- ...

---

## 🔧 常见问题

### 编译错误

#### 问题: `arkts-no-any-unknown` 错误
```typescript
// ❌ 错误
private data: any;

// ✅ 解决
import resourceManager from '@ohos.resourceManager';
private data: resourceManager.RawFileDescriptor | null;
```

#### 问题: 对象字面量错误
```typescript
// ❌ 错误
const level: Level = { levelId: 'id', name: 'test' };

// ✅ 解决
const level = new Level('id', 'test', 9, 9, 10, true);
```

### 运行问题

#### 问题: 音频无法播放
**解决方案**: 
1. 检查 AVPlayer 状态机是否正确
2. 确认使用事件驱动方式
3. 查看控制台日志

#### 问题: 字体不显示
**解决方案**:
1. 确认字体文件在 `rawfile/fonts/` 目录
2. 检查 `EntryAbility` 中是否注册字体
3. 使用字体回退机制

---

## 📊 性能指标

| 指标 | 目标值 | 说明 |
|-----|--------|------|
| 应用启动时间 | < 2s | 冷启动到主页面 |
| 页面切换 | < 300ms | 流畅的转场动画 |
| 音频响应 | < 100ms | 触发到播放 |
| 内存占用 | < 200MB | 正常游戏状态 |
| 帧率 | 60fps | 流畅的动画和交互 |

---

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

### 贡献流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 报告问题

在提交 Issue 时，请包含：
- 问题描述
- 复现步骤
- 预期行为
- 实际行为
- 截图（如果适用）
- 设备信息和 HarmonyOS 版本

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 👥 作者

- **开发者**: [Your Name]
- **邮箱**: your.email@example.com
- **项目主页**: [GitHub](https://github.com/yourusername/SheepMinesweeper)

---

## 🙏 致谢

- 感谢 HarmonyOS 团队提供优秀的开发平台
- 感谢《喜羊羊与灰太狼》提供游戏灵感
- 感谢所有贡献者和测试者

---

## 📮 联系方式

如有问题或建议，请通过以下方式联系：

- **Issue**: [GitHub Issues](https://github.com/yourusername/SheepMinesweeper/issues)
- **Email**: your.email@example.com
- **HarmonyOS 开发者论坛**: [论坛链接]

---

**⭐ 如果这个项目对你有帮助，请给个星标！**

---

## 📝 更新日志

### v1.0.0 (2025-10-11)
- ✨ 完整的扫雷游戏功能
- 🎨 6个角色主题
- 🎵 完整的音频系统
- 🏆 成就系统
- 🎮 多种游戏模式
- 🛠️ 符合 ArkTS 规范的代码

---

**Made with ❤️ for HarmonyOS**


