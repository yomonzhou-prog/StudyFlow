import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'StudyFlow', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'StudyFlow', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'StudyFlow', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/HomePage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'StudyFlow', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(0x0000, 'StudyFlow', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'StudyFlow', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'StudyFlow', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'StudyFlow', 'Ability onBackground');
  }
}
