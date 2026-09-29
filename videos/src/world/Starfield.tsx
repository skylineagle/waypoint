import { random } from "remotion";
import type { FC } from "react";
import { useTime } from "../useTime";
import { distance, speed } from "./travel";

const COUNT = 240;
const DEPTH = 3200;
const FOCAL = 700;
const CENTER_X = 540;
const CENTER_Y = 880;

const stars = Array.from({ length: COUNT }, (_, index) => ({
  x: (random(`sx${index}`) - 0.5) * 3600,
  y: (random(`sy${index}`) - 0.5) * 4200,
  z: random(`sz${index}`) * DEPTH,
}));

const project = (x: number, y: number, z: number) => ({ x: CENTER_X + (FOCAL * x) / z, y: CENTER_Y + (FOCAL * y) / z });

export const Starfield: FC = () => {
  const time = useTime();
  const travelled = distance(time);
  const tail = Math.min(1400, speed(time) * 0.07);
  return (
    <svg width={1080} height={1920} style={{ position: "absolute", inset: 0 }}>
      {stars.map((star, index) => {
        const depth = ((((star.z - travelled) % DEPTH) + DEPTH) % DEPTH) + 80;
        const head = project(star.x, star.y, depth);
        const back = project(star.x, star.y, depth + tail);
        const nearness = 1 - depth / (DEPTH + 80);
        return (
          <line
            key={index}
            x1={head.x}
            y1={head.y}
            x2={back.x}
            y2={back.y}
            stroke="#fff"
            strokeLinecap="round"
            strokeWidth={Math.min(5, Math.max(1.2, (2.4 * FOCAL) / depth))}
            opacity={0.15 + 0.7 * nearness}
          />
        );
      })}
    </svg>
  );
};
