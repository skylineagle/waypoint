import type { FC } from "react";
import { easeOut, lerp, progress, springAt } from "../motion";
import { useTime } from "../useTime";
import { crops } from "./crops";
import { ElementCrop } from "./ElementCrop";

export type IslandPillProps = { at: number; width: number };

const IDLE_WIDTH = 250;

export const IslandPill: FC<IslandPillProps> = ({ at, width }) => {
  const time = useTime();
  if (time < at) return null;
  const grow = springAt(time - at - 0.12, 14, 140);
  const appear = progress(time, at, 0.2, easeOut);
  const content = progress(time, at + 0.3, 0.25);
  const height = (crops.island.height / crops.island.width) * width;
  const currentWidth = lerp(IDLE_WIDTH, width, grow);
  const currentHeight = lerp(height * 0.78, height, grow);
  return (
    <div
      style={{
        position: "relative",
        width: currentWidth,
        height: currentHeight,
        borderRadius: 999,
        backgroundColor: "#000",
        overflow: "hidden",
        opacity: appear,
        boxShadow: "0 50px 110px rgba(0,0,0,0.6), 0 0 0 2px rgba(165,180,252,0.3)",
      }}
    >
      <div style={{ position: "absolute", left: (currentWidth - width) / 2, top: (currentHeight - height) / 2, opacity: content }}>
        <ElementCrop region={crops.island} width={width} lift={0} />
      </div>
    </div>
  );
};
