import type { FC } from "react";
import type { SceneWindow } from "../cues";
import { crops } from "../ui/crops";
import { ElementPop } from "../ui/ElementPop";
import { Headline } from "../ui/Headline";
import { Phone } from "../ui/Phone";
import { Shot } from "../ui/Shot";
import { Stage } from "../ui/Stage";

export type CostsSceneProps = { window: SceneWindow };

const PHONE = { x: -175, y: 190, width: 540 };

export const CostsScene: FC<CostsSceneProps> = ({ window }) => (
  <Shot window={window}>
    <Stage window={window} orbitFrom={-8} orbitTo={7}>
      <Phone placement={PHONE} screen="menu-dark" />
      <ElementPop region={crops.costsTotal} phone={PHONE} to={{ x: 180, y: -150, z: 200, width: 560, rotateY: -8 }} at={window.start + 0.4} />
      <ElementPop region={crops.costsCurrency} phone={PHONE} to={{ x: 190, y: 190, z: 260, width: 560, rotateY: -8 }} at={window.start + 0.9} />
      <ElementPop region={crops.receiptMenu} phone={PHONE} to={{ x: 170, y: 500, z: 330, width: 460, rotateY: -8 }} at={window.start + 1.4} />
    </Stage>
    <Headline eyebrow="costs" line="Every expense," accent="any currency." at={window.start + 0.1} />
  </Shot>
);
