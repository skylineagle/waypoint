import { AbsoluteFill, Audio, staticFile } from "remotion";
import { useState, type FC } from "react";
import { fontFaceCss, holdUntilFontsLoad } from "../fonts";
import { easeIn, progress, springAt } from "../motion";
import { phoneMetrics } from "../ui/phoneGeometry";
import { useTime } from "../useTime";
import { Backdrop } from "./Backdrop";
import { ChapterCaption } from "./ChapterCaption";
import { chapters, finale, HEIGHT, opening } from "./cues";
import { DayPhone } from "./DayPhone";
import { FinaleScene } from "./scenes/FinaleScene";
import { OpeningScene } from "./scenes/OpeningScene";

export type ShowcaseProps = { withAudio?: boolean };

const PHONE_WIDTH = 450;
const PHONE_LEFT = 1180;
const PHONE_TOP = (HEIGHT - phoneMetrics(PHONE_WIDTH).height) / 2;

export const Showcase: FC<ShowcaseProps> = ({ withAudio = true }) => {
  useState(holdUntilFontsLoad);
  const time = useTime();
  const rise = springAt(time - opening.end + 0.45, 18, 90);
  const drop = progress(time, finale.start - 0.3, 0.7, easeIn);
  const phoneVisible = rise > 0 && drop < 1;
  return (
    <AbsoluteFill>
      <style>{fontFaceCss}</style>
      <Backdrop />
      <OpeningScene window={opening} />
      {phoneVisible && (
        <div style={{ position: "absolute", left: PHONE_LEFT, top: PHONE_TOP + (1 - rise) * 1100 + drop * 1100 }}>
          <DayPhone width={PHONE_WIDTH} />
        </div>
      )}
      {chapters.map((chapter) => (
        <ChapterCaption key={chapter.clip} chapter={chapter} left={200} width={820} />
      ))}
      <FinaleScene window={finale} />
      {withAudio && <Audio src={staticFile("audio/showcase.wav")} />}
    </AbsoluteFill>
  );
};
