// Common.ets
import { display } from '@kit.ArkUI';

const TAG: string = 'ScanKit common';
// 相机预览流比例，常用比例为1、4/3，16/9，可以自定义设置比例
let ratios: Array<number> = [1, 4 / 3, 16 / 9];

export interface xComDisplay {
  width: number,
  height: number,
  offsetX: number,
  offsetY: number
}

// 获取宽高比例最匹配设置的ratios比例值
function getRatio(ratio: number): number {
  let setRatio: number = ratio < 1 ? (1 / ratio) : ratio;
  let result: number = ratios[0];
  let minNo: number = Math.abs(setRatio - ratios[0]);
  for (let i = 1; i < ratios.length; i++) {
    if (Math.abs(setRatio - ratios[i]) < minNo) {
      minNo = Math.abs(setRatio - ratios[i]);
      result = ratios[i];
    }
  }
  return result;
}

// 获取全屏比例尺寸xComponent大小
export function getXComDisplay(): xComDisplay {
  // 获取屏幕尺寸
  let displayClass = display.getDefaultDisplaySync();
  let width: number = px2vp(displayClass.width);
  let height: number = px2vp(displayClass.height);
  let result: xComDisplay = {
    width: 360,
    height: 640,
    offsetX: 0,
    offsetY: 0
  };
  let defaultRatio: number = getRatio(height / width);
  console.info(TAG, `defaultRatio: ${defaultRatio}`);
  if (height / width >= defaultRatio) {
    result.height = height;
    result.width = height / defaultRatio;
    result.offsetX = (width - result.width) / 2;
    result.offsetY = 0;
  } else {
    result.width = width;
    result.height = width * defaultRatio;
    result.offsetX = 0;
    result.offsetY = (height - result.height) / 2;
  }
  return result;
}