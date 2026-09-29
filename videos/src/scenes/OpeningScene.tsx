import type { FC } from "react";
import type { SceneWindow } from "../cues";
import { beat } from "../cues";
import { springAt } from "../motion";
import { fonts, nightAccent } from "../theme";
import { AppIcon } from "../ui/AppIcon";
import { Placed } from "../ui/Placed";
import { Shot } from "../ui/Shot";
import { Stage } from "../ui/Stage";
import { Words } from "../ui/Words";
import { Wordmark } from "../ui/Wordmark";
import { useTime } from "../useTime";

export type OpeningSceneProps = { window: SceneWindow };

export const OpeningScene: FC<OpeningSceneProps> = ({ window }) => {
  const time = useTime();
  const icon = springAt(time + 0.08, 13, 100);
  const lineStyle = { fontFamily: fonts.body, fontSize: 104, fontWeight: 700, letterSpacing: -3, lineHeight: 1.06, color: "#fff", textAlign: "center" } as const;
  return (
    <Shot window={window} enters={false}>
      <Stage window={window} orbitFrom={-10} orbitTo={8} tilt={2}>
        <Placed y={-330} z={-700 * (1 - icon)} rotateY={40 * (1 - icon)} scale={Math.max(0.001, icon)} opacity={Math.min(1, icon * 2)}>
          <AppIcon size={330} />
        </Placed>
        <Placed y={-40} z={40}>
          <Wordmark at={beat(1)} size={176} />
        </Placed>
      </Stage>
      <div style={{ position: "absolute", left: 0, right: 0, top: 1180 }}>
        <Words text="Your trip," at={beat(3)} style={lineStyle} />
        <Words
          text="stop by stop."
          at={beat(4)}
          style={lineStyle}
          wordStyle={{ background: nightAccent, WebkitBackgroundClip: "text", color: "transparent", paddingBottom: 8 }}
        />
      </div>
    </Shot>
  );
};
