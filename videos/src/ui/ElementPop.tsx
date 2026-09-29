import type { FC } from "react";
import { lerp, springAt } from "../motion";
import { useTime } from "../useTime";
import type { CropRegion } from "./crops";
import { ElementCrop } from "./ElementCrop";
import { phoneMetrics, type Placement } from "./phoneGeometry";
import { Placed } from "./Placed";

export type PopTarget = Placement & { z: number; rotateY?: number };

export type ElementPopProps = { region: CropRegion; phone: Placement; to: PopTarget; at: number };

export const ElementPop: FC<ElementPopProps> = ({ region, phone, to, at }) => {
  const time = useTime();
  if (time < at) return null;
  const { bezel, height, scale } = phoneMetrics(phone.width);
  const fromX = phone.x - phone.width / 2 + bezel + (region.x + region.width / 2) * scale;
  const fromY = phone.y - height / 2 + bezel + (region.y + region.height / 2) * scale;
  const lift = springAt(time - at, 15, 110);
  const settle = Math.min(1, (time - at) / 0.6);
  const bob = Math.sin((time - at) * 2.2) * 8 * settle;
  return (
    <Placed x={lerp(fromX, to.x, lift)} y={lerp(fromY, to.y, lift) + bob} z={lerp(1, to.z, lift)} rotateY={lerp(0, to.rotateY ?? 0, lift)}>
      <ElementCrop region={region} width={lerp(region.width * scale, to.width, lift)} lift={Math.min(1, lift)} />
    </Placed>
  );
};
