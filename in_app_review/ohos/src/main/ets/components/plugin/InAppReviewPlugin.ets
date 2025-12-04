import deviceInfo from '@kit.DeviceInfoKit';
import { commentManager} from '@kit.AppGalleryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import type { common } from '@kit.AbilityKit';
import {
  FlutterPlugin,
  AbilityAware,
  FlutterPluginBinding,
  AbilityPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

/** InAppReviewPlugin **/
export default class InAppReviewPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private context: common.UIAbilityContext | null = null;

  private channel: MethodChannel | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "InAppReviewPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "in_app_review");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context
  }

  onDetachedFromAbility(): void {
    this.context = null
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "requestReview":
        requestReview(result)
        break;
      case "isAvailable":
        let deviceInfoObj = deviceInfo.getDeviceInfo();
        let sdkVersion = deviceInfoObj.sdkApiVersion;
        // HarmonyOS 6.0 对应 API 20
        result.success(sdkVersion >= 20);
      case "openStoreListing":
        result.notImplemented()
        break;
      default:
        result.notImplemented()
        break;
    }
  }

  requestReview(result: MethodResult): void {
    try {
      commentManager.showCommentDialog(this.context!).then(()=>{
        result.success(true)
      }).catch((error: BusinessError<Object>) => {
        result.error('' + error.code, error.message, error)
      });
    } catch (error) {
      result.error('' + error.code, error.message, error)
    }
  }
}