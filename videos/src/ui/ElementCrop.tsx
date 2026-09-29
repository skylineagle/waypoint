import { Img, staticFile } from "remotion";
import type { FC } from "react";
import { SOURCE_HEIGHT, SOURCE_WIDTH } from "../theme";
import type { CropRegion } from "./crops";

export type ElementCropProps = { region: CropRegion; width: number; lift: number };

export const ElementCrop: FC<ElementCropProps> = ({ region, width, lift }) => {
  const scale = width / region.width;
  return (
    <div
      style={{
        position: "relative",
        width,
        height: region.height * scale,
        borderRadius: region.radius * scale,
        overflow: "hidden",
        boxShadow: `0 ${70 * lift}px ${130 * lift}px rgba(0,0,0,${0.6 * lift}), 0 0 0 2px rgba(165,180,252,${0.35 * lift})`,
      }}
    >
      <Img
        src={staticFile(`raw/${region.image}.png`)}
        style={{ position: "absolute", left: -region.x * scale, top: -region.y * scale, width: SOURCE_WIDTH * scale, height: SOURCE_HEIGHT * scale, maxWidth: "none" }}
      />
    </div>
  );
};
