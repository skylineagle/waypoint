import { AbsoluteFill } from "remotion";
import type { FC } from "react";
import { easeIn, progress, springAt } from "../../motion";
import { colors, fonts } from "../../theme";
import { AppIcon } from "../../ui/AppIcon";
import { Wordmark } from "../../ui/Wordmark";
import { Words } from "../../ui/Words";
import { useTime } from "../../useTime";
import { at, type SceneWindow } from "../cues";

export type OpeningSceneProps = { window: SceneWindow };

export const OpeningScene: FC<OpeningSceneProps> = ({ window }) => {
  const time = useTime();
  if (time > window.end + 0.1) return null;
  const icon = springAt(time + 0.1, 14, 110);
  const leave = progress(time, window.end - 0.5, 0.5, easeIn);
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", opacity: 1 - leave, translate: `0 ${-40 * leave}px` }}>
      <div style={{ scale: `${Math.max(0.001, icon)}`, opacity: Math.min(1, icon * 2) }}>
        <AppIcon size={200} />
      </div>
      <div style={{ marginTop: 36 }}>
        <Wordmark at={at(0, 1)} size={140} />
      </div>
      <Words text="A day in Tokyo." at={at(1)} style={{ marginTop: 30, fontFamily: fonts.body, fontSize: 44, fontWeight: 600, color: colors.soft }} />
    </AbsoluteFill>
  );
};
