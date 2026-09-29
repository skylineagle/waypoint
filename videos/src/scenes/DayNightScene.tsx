import { AbsoluteFill } from "remotion";
import type { FC } from "react";
import { DROP, type SceneWindow } from "../cues";
import { easeInOut, progress } from "../motion";
import { ThemeToggle } from "../ui/ThemeToggle";
import { ENTER_LEAD, Shot } from "../ui/Shot";
import { useTime } from "../useTime";
import { DayBackdrop } from "../world/DayBackdrop";
import { DayNightSet } from "./DayNightSet";

export type DayNightSceneProps = { window: SceneWindow };

const TOGGLE_TOP = 520;
const TOGGLE_CENTER = { x: 540, y: TOGGLE_TOP + 42 };

export const DayNightScene: FC<DayNightSceneProps> = ({ window }) => {
  const time = useTime();
  const wipe = progress(time, DROP, 0.75, easeInOut) * 2400;
  const dayMask = `radial-gradient(circle at ${TOGGLE_CENTER.x}px ${TOGGLE_CENTER.y}px, transparent ${wipe}px, #000 ${wipe + 2}px)`;
  const dayIn = progress(time, window.start - ENTER_LEAD - 0.1, 0.5, easeInOut);
  const showDay = time >= window.start - ENTER_LEAD - 0.1 && wipe < 2400;
  const toggle = (
    <div style={{ position: "absolute", top: TOGGLE_TOP, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
      <ThemeToggle switchAt={DROP} />
    </div>
  );
  return (
    <>
      {showDay && (
        <AbsoluteFill style={{ opacity: dayIn, WebkitMaskImage: dayMask }}>
          <DayBackdrop />
        </AbsoluteFill>
      )}
      <Shot window={window}>
        <AbsoluteFill>
          <DayNightSet window={window} tone="night" />
          {toggle}
        </AbsoluteFill>
        {showDay && (
          <AbsoluteFill style={{ WebkitMaskImage: dayMask }}>
            <DayNightSet window={window} tone="day" />
            {toggle}
          </AbsoluteFill>
        )}
      </Shot>
    </>
  );
};
