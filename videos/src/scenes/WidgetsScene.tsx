import type { FC } from "react";
import type { SceneWindow } from "../cues";
import { crops } from "../ui/crops";
import { ElementPop } from "../ui/ElementPop";
import { Headline } from "../ui/Headline";
import { Phone } from "../ui/Phone";
import { Shot } from "../ui/Shot";
import { Stage } from "../ui/Stage";

export type WidgetsSceneProps = { window: SceneWindow };

const PHONE = { x: -175, y: 190, width: 540 };

export const WidgetsScene: FC<WidgetsSceneProps> = ({ window }) => (
  <Shot window={window}>
    <Stage window={window} orbitFrom={8} orbitTo={-6}>
      <Phone placement={PHONE} screen="home-light" />
      <ElementPop region={crops.widgetMedium} phone={PHONE} to={{ x: 150, y: -110, z: 220, width: 700, rotateY: -8 }} at={window.start + 0.4} />
      <ElementPop region={crops.widgetSmall} phone={PHONE} to={{ x: 250, y: 330, z: 300, width: 380, rotateY: -8 }} at={window.start + 0.9} />
    </Stage>
    <Headline eyebrow="widgets" line="On your" accent="Home Screen." at={window.start + 0.1} />
  </Shot>
);
