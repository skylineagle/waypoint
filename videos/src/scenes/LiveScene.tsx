import type { FC } from "react";
import type { SceneWindow } from "../cues";
import { progress } from "../motion";
import { crops } from "../ui/crops";
import { ElementPop } from "../ui/ElementPop";
import { Headline } from "../ui/Headline";
import { IslandPill } from "../ui/IslandPill";
import { Phone } from "../ui/Phone";
import { Placed } from "../ui/Placed";
import { Shot } from "../ui/Shot";
import { Stage } from "../ui/Stage";
import { useTime } from "../useTime";

export type LiveSceneProps = { window: SceneWindow };

const PHONE = { x: 0, y: 200, width: 540 };
const SWAP = 2;

export const LiveScene: FC<LiveSceneProps> = ({ window }) => {
  const time = useTime();
  const swap = window.start + SWAP;
  const firstOut = progress(time, swap - 0.25, 0.25);
  return (
    <Shot window={window}>
      <Stage window={window} orbitFrom={-8} orbitTo={8}>
        <Phone placement={PHONE} screen="lock" />
        <ElementPop region={crops.liveActivity} phone={PHONE} to={{ x: 0, y: 330, z: 280, width: 880 }} at={window.start + 0.5} />
        <Placed y={-250} z={340}>
          <IslandPill at={swap} width={780} />
        </Placed>
      </Stage>
      <div style={{ opacity: 1 - firstOut, transform: `translateY(${-40 * firstOut}px)` }}>
        <Headline eyebrow="live activity" line="Your day on the" accent="Lock Screen." at={window.start + 0.1} />
      </div>
      {time >= swap && <Headline eyebrow="live activity" line="And in the" accent="Dynamic Island." at={swap} />}
    </Shot>
  );
};
