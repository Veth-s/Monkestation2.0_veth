import { text } from '../styles/atomic';

import { Section, LabeledList } from '../components';
import { Window } from '../layouts';
import { useBackend } from '../backend';

type Data = {
  total_clients: string;
  living_players: string;
  dead_players: string;
  ghost_players: string;
  living_antags: string;
};

export const PlayerStatistics = () => {
  const { data } = useBackend<Data>();
  return (
    <Window title="Player Statistics" width={400} height={180} theme="admin">
      <Section title="Player Overview">
        <LabeledList>
          <LabeledList.Item
            label={
              <div className="text-bold" style={{ color: '#4287f5' }}>
                Total Clients:
              </div>
            }
          >
            {data.total_clients}
          </LabeledList.Item>
          <LabeledList.Item
            label={
              <div className="text-bold" style={{ color: '#1d9123' }}>
                Living Players:
              </div>
            }
          >
            {data.living_players}
          </LabeledList.Item>
          <LabeledList.Item
            label={
              <div className="text-bold" style={{ color: '#666e66' }}>
                Dead Players:
              </div>
            }
          >
            {data.dead_players}
          </LabeledList.Item>
          <LabeledList.Item
            label={
              <div className="text-bold" style={{ color: '#34949e' }}>
                Ghost Players:
              </div>
            }
          >
            {data.ghost_players}
          </LabeledList.Item>
          <LabeledList.Item
            label={
              <div className="text-bold" style={{ color: '#bd2924' }}>
                Living Antags:
              </div>
            }
          >
            {data.living_antags}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Window>
  );
};
