# English Vocabulary Learning App

一个专为中文用户设计的iOS英语词汇学习应用，支持抽认卡、测验、间隔重复和进度跟踪功能。

## 功能特点

### 🎯 核心学习功能
- **抽认卡学习**: 互动式抽认卡，支持翻转动画和手势操作
- **智能测验**: 选择题和拼写题两种测验模式
- **间隔重复**: 基于SuperMemo SM-2算法的智能复习系统
- **进度跟踪**: 详细的学习统计和成就系统

### 📚 词汇内容
- **预加载词汇**: 150+个中等难度英语单词
- **分类学习**: 商务、学术、日常生活、科技、旅行五大分类
- **双语支持**: 英文单词配中文释义和例句

### 📊 学习统计
- **学习连续天数**: 追踪每日学习习惯
- **准确率统计**: 详细的答题正确率分析
- **分类进度**: 各个词汇分类的学习进度
- **成就系统**: 多种学习成就徽章激励

## 技术架构

### 🛠 开发技术
- **SwiftUI**: 现代化的iOS用户界面框架
- **Core Data**: 本地数据持久化存储
- **MVVM架构**: 清晰的代码组织结构
- **Mac Catalyst**: 支持在Mac上运行

### 📱 系统要求
- iOS 15.0 或更高版本
- 支持iPhone和iPad
- 兼容Mac Air (通过Mac Catalyst)

## 项目结构

```
EnglishVocabulary/
├── EnglishVocabularyApp.swift          # 应用入口
├── ContentView.swift                   # 主界面导航
├── Models/                             # 数据模型
│   ├── VocabularyModel.xcdatamodeld   # Core Data模型
│   ├── PersistenceController.swift    # 数据持久化控制器
│   └── SpacedRepetitionManager.swift  # 间隔重复算法
├── Views/                              # 用户界面
│   ├── StudyView.swift                # 学习界面
│   ├── FlashcardView.swift            # 抽认卡组件
│   ├── QuizView.swift                 # 测验选择界面
│   ├── MultipleChoiceQuiz.swift       # 选择题测验
│   ├── SpellingQuiz.swift             # 拼写测验
│   ├── ProgressView.swift             # 进度统计界面
│   └── SettingsView.swift             # 设置界面
├── Data/                               # 数据文件
│   └── VocabularyData.swift           # 预加载词汇数据
└── Assets.xcassets/                    # 应用资源
```

## 安装和运行

### 在Mac Air上测试

1. **克隆项目**
   ```bash
   git clone https://github.com/kchen9530/ios-english-learn.git
   cd ios-english-learn
   ```

2. **打开Xcode项目**
   ```bash
   open EnglishVocabulary.xcodeproj
   ```

3. **选择运行目标**
   - 对于iOS模拟器: 选择任意iOS设备模拟器
   - 对于Mac预览: 选择"My Mac (Mac Catalyst)"

4. **构建和运行**
   - 按 `Cmd + R` 或点击运行按钮
   - 应用将在选择的目标设备上启动

### 系统要求
- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本
- iOS 15.0 部署目标

## 使用指南

### 📖 学习模式
1. **抽认卡学习**
   - 点击卡片查看中文释义
   - 向右滑动表示"简单"
   - 向左滑动表示"困难"
   - 点击底部按钮进行评分

2. **测验模式**
   - 选择题: 从四个选项中选择正确的中文释义
   - 拼写题: 根据中文释义拼写英文单词
   - 实时显示得分和进度

3. **智能复习**
   - 系统根据你的表现自动安排复习时间
   - 困难的单词会更频繁地出现
   - 掌握的单词复习间隔会逐渐延长

### 📊 进度跟踪
- 查看学习连续天数和总体统计
- 分析各分类词汇的掌握情况
- 解锁各种学习成就徽章
- 监控学习准确率变化

## 开发说明

### 核心算法
应用使用改进的SuperMemo SM-2间隔重复算法:
- 初次学习: 1天后复习
- 第二次: 6天后复习
- 后续: 根据难易程度调整间隔
- 错误答案会重置复习间隔

### 数据存储
- 使用Core Data进行本地数据持久化
- 自动备份学习进度和统计数据
- 支持iCloud同步(未来版本)

## 贡献

欢迎提交Issue和Pull Request来改进这个应用！

## 许可证

MIT License

## 联系方式

如有问题或建议，请通过GitHub Issues联系。

---

**Link to Devin run**: https://app.devin.ai/sessions/a408dd85cc3d4a1f8f417fbda6f25332

**Requested by**: @kchen9530
