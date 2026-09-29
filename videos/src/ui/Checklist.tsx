import type { FC } from "react";
import { colors } from "../theme";
import { ChecklistItem } from "./ChecklistItem";

export type ChecklistStep = { label: string; at: number };

export type ChecklistProps = { steps: ChecklistStep[]; finishedAt: number };

export const Checklist: FC<ChecklistProps> = ({ steps, finishedAt }) => (
  <div
    style={{
      padding: "14px 30px",
      borderRadius: 36,
      backgroundColor: colors.card,
      boxShadow: `0 60px 120px rgba(0,0,0,0.55), 0 0 0 2px ${colors.ring}`,
    }}
  >
    {steps.map((step, index) => (
      <ChecklistItem key={step.label} label={step.label} activeAt={step.at} doneAt={steps[index + 1]?.at ?? finishedAt} />
    ))}
  </div>
);
