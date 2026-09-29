import type { FC } from "react";
import { colors, fonts } from "../theme";
import { useTime } from "../useTime";
import { interpolate } from "remotion";
import { distance } from "./travel";

const FOCAL = 700;
const CAMERA_HEIGHT = 420;
const HORIZON = 1010;
const DOT_SPACING = 70;
const PIN_SPACING = 1500;
const FAR = 6000;
const NEAR = 240;

const pathX = (z: number) => 380 * Math.sin(z / 900) + 170 * Math.sin(z / 370);

const fade = (depth: number) => Math.min(1, (depth - NEAR) / 200) * Math.min(1, (FAR - depth) / 2000);

export const Route: FC = () => {
  const time = useTime();
  const travelled = distance(time) * 1.4;
  const visibility = interpolate(time, [0.6, 1.2, 3.6, 4.1, 27.6, 28.3], [1, 0.35, 0.35, 1, 1, 0.3], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const cameraX = pathX(travelled + 700) * 0.85;
  const project = (z: number) => {
    const depth = z - travelled;
    return { x: 540 + (FOCAL * (pathX(z) - cameraX)) / depth, y: HORIZON + (FOCAL * CAMERA_HEIGHT) / depth, depth };
  };
  const firstDot = Math.ceil((travelled + NEAR) / DOT_SPACING);
  const dots = Array.from({ length: Math.floor((FAR - NEAR) / DOT_SPACING) }, (_, index) => project((firstDot + index) * DOT_SPACING));
  const firstPin = Math.ceil((travelled + NEAR) / PIN_SPACING);
  const pins = Array.from({ length: 4 }, (_, index) => ({ number: firstPin + index, ...project((firstPin + index) * PIN_SPACING) }));
  return (
    <svg width={1080} height={1920} style={{ position: "absolute", inset: 0, opacity: visibility }}>
      {dots.map((dot, index) => (
        <circle key={index} cx={dot.x} cy={dot.y} r={Math.max(1.5, (9 * FOCAL) / dot.depth)} fill={colors.soft} opacity={0.75 * fade(dot.depth)} />
      ))}
      {pins
        .slice()
        .reverse()
        .map((pin) => {
          const radius = (46 * FOCAL) / pin.depth;
          const lift = radius * 1.6;
          return (
            <g key={pin.number} opacity={fade(pin.depth)}>
              <circle cx={pin.x} cy={pin.y - lift} r={radius * 1.9} fill="rgba(165,180,252,0.18)" />
              <circle cx={pin.x} cy={pin.y - lift} r={radius} fill={colors.ink} stroke="#fff" strokeWidth={radius * 0.16} />
              <text
                x={pin.x}
                y={pin.y - lift}
                fill="#fff"
                fontFamily={fonts.body}
                fontWeight={700}
                fontSize={radius * 1.05}
                textAnchor="middle"
                dominantBaseline="central"
              >
                {pin.number}
              </text>
            </g>
          );
        })}
    </svg>
  );
};
