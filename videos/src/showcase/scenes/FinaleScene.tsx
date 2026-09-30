import { AbsoluteFill } from "remotion";
import type { FC } from "react";
import { progress, springAt } from "../../motion";
import { colors, fonts } from "../../theme";
import { AppIcon } from "../../ui/AppIcon";
import { Wordmark } from "../../ui/Wordmark";
import { Words } from "../../ui/Words";
import { useTime } from "../../useTime";
import { BEAT, type SceneWindow } from "../cues";

export type FinaleSceneProps = { window: SceneWindow };

export const FinaleScene: FC<FinaleSceneProps> = ({ window }) => {
  const time = useTime();
  if (time < window.start - 0.2) return null;
  const icon = springAt(time - window.start - 0.2, 14, 110);
  const fadeOut = progress(time, window.end - 0.8, 0.8);
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", opacity: 1 - fadeOut }}>
      <div style={{ scale: `${Math.max(0.001, icon)}`, opacity: Math.min(1, icon * 2) }}>
        <AppIcon size={200} />
      </div>
      <div style={{ marginTop: 36 }}>
        <Wordmark at={window.start + 0.35} size={140} />
      </div>
      <Words text="Your trip, stop by stop." at={window.start + BEAT * 3} style={{ marginTop: 30, fontFamily: fonts.body, fontSize: 44, fontWeight: 600, color: colors.soft }} />
      <Words text="The iPhone companion for your self-hosted TREK." at={window.start + BEAT * 5} stagger={0.04} style={{ marginTop: 18, fontFamily: fonts.body, fontSize: 30, color: colors.muted }} />
    </AbsoluteFill>
  );
};
