import type { FC } from "react";
import type { Placement } from "./phoneGeometry";
import { PhoneFrame } from "./PhoneFrame";
import { Placed } from "./Placed";
import { ScreenImage } from "./ScreenImage";

export type PhoneProps = { placement: Placement; screen: string; z?: number; rotateY?: number };

export const Phone: FC<PhoneProps> = ({ placement, screen, z = 0, rotateY = 0 }) => (
  <Placed x={placement.x} y={placement.y} z={z} rotateY={rotateY}>
    <PhoneFrame width={placement.width}>
      <ScreenImage name={screen} />
    </PhoneFrame>
  </Placed>
);
