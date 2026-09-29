import { SOURCE_HEIGHT, SOURCE_WIDTH } from "../theme";

export type Placement = { x: number; y: number; width: number };

export const BEZEL_RATIO = 0.022;

export const phoneMetrics = (width: number) => {
  const bezel = width * BEZEL_RATIO;
  const screenWidth = width - bezel * 2;
  const screenHeight = (screenWidth * SOURCE_HEIGHT) / SOURCE_WIDTH;
  return { bezel, screenWidth, screenHeight, height: screenHeight + bezel * 2, scale: screenWidth / SOURCE_WIDTH };
};
