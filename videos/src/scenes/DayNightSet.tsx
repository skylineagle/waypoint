import type { FC } from "react";
import type { SceneWindow } from "../cues";
import { Headline } from "../ui/Headline";
import { Phone } from "../ui/Phone";
import { Stage } from "../ui/Stage";

export type DayNightSetProps = { window: SceneWindow; tone: "day" | "night" };

export const DayNightSet: FC<DayNightSetProps> = ({ window, tone }) => {
  const suffix = tone === "day" ? "light" : "dark";
  return (
    <>
      <Stage window={window} orbitFrom={-6} orbitTo={6}>
        <Phone placement={{ x: -370, y: 300, width: 380 }} z={-220} rotateY={22} screen={`costs-${suffix}`} />
        <Phone placement={{ x: 370, y: 300, width: 380 }} z={-220} rotateY={-22} screen={`home-${suffix}`} />
        <Phone placement={{ x: 0, y: 260, width: 500 }} z={60} screen={`today-${suffix}`} />
      </Stage>
      <Headline eyebrow="light & dark" line="Day or night," accent="it looks right." at={window.start + 0.1} tone={tone} />
    </>
  );
};
