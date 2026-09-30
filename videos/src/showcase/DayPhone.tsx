import { OffthreadVideo, Sequence, staticFile } from "remotion";
import type { FC } from "react";
import { progress } from "../motion";
import { phoneMetrics } from "../ui/phoneGeometry";
import { useTime } from "../useTime";
import { chapters, FPS } from "./cues";

export type DayPhoneProps = { width: number };

const FADE = 0.35;
const INTRO_LEAD = 0.6;

export const DayPhone: FC<DayPhoneProps> = ({ width }) => {
  const time = useTime();
  const { bezel, screenWidth, screenHeight } = phoneMetrics(width);
  const radius = screenWidth * 0.118;
  return (
    <div style={{ width, padding: bezel, borderRadius: radius + bezel, backgroundColor: "#0b0f1c", boxShadow: "0 0 0 2px #2a3042, 0 50px 110px rgba(0,0,0,0.55)" }}>
      <div style={{ position: "relative", width: screenWidth, height: screenHeight, borderRadius: radius, overflow: "hidden", backgroundColor: "#000" }}>
        {chapters.map(({ clip, window, trimStart, trimEnd }, index) => {
          const rate = (trimEnd - trimStart) / (window.end - window.start);
          const early = index === 0 ? INTRO_LEAD : FADE;
          const from = Math.round((window.start - early) * FPS);
          const lead = early * rate;
          const until = index === chapters.length - 1 ? window.end + 2 : window.end + FADE;
          return (
            <Sequence key={clip} from={from} durationInFrames={Math.round((until - window.start + early) * FPS)} layout="none">
              <div style={{ position: "absolute", inset: 0, opacity: index === 0 ? 1 : progress(time, window.start - FADE, FADE) }}>
                <OffthreadVideo
                  src={staticFile(`rec/${clip}.mp4`)}
                  startFrom={Math.round(Math.max(0, trimStart - lead) * FPS)}
                  playbackRate={rate}
                  muted
                  style={{ width: "100%", height: "100%" }}
                />
              </div>
            </Sequence>
          );
        })}
      </div>
    </div>
  );
};
