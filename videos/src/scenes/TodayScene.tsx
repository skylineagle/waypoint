import type { FC } from "react";
import type { SceneWindow } from "../cues";
import { crops } from "../ui/crops";
import { ElementPop } from "../ui/ElementPop";
import { Headline } from "../ui/Headline";
import { Phone } from "../ui/Phone";
import { Shot } from "../ui/Shot";
import { Stage } from "../ui/Stage";

export type TodaySceneProps = { window: SceneWindow };

const PHONE = { x: -175, y: 190, width: 540 };

export const TodayScene: FC<TodaySceneProps> = ({ window }) => (
  <Shot window={window}>
    <Stage window={window} orbitFrom={9} orbitTo={-7}>
      <Phone placement={PHONE} screen="today-light" />
      <ElementPop region={crops.todayMap} phone={PHONE} to={{ x: 185, y: -90, z: 200, width: 580, rotateY: -8 }} at={window.start + 0.5} />
      <ElementPop region={crops.todayUpNext} phone={PHONE} to={{ x: 170, y: 330, z: 300, width: 620, rotateY: -6 }} at={window.start + 1.0} />
    </Stage>
    <Headline eyebrow="today" line="Always know" accent="what's next." at={window.start + 0.1} />
  </Shot>
);
