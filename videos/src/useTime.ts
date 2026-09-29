import { useCurrentFrame, useVideoConfig } from "remotion";

export const useTime = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return frame / fps;
};
