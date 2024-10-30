import { Section, LabeledList } from '../components';
import { Window } from '../layouts';
import { useBackend } from '../backend';

type Data = {
  total_clients: string;
  living_players: string;
  dead_players: string;
  observers: string;
  living_antags: string;
};

export const PlayerStatistics = () => {
  const { data } = useBackend<Data>();

  return (
    <Window title="Player Statistics" width={400} height={180} theme="admin">
      <Section title="Player Overview">
        <LabeledList>
          <LabeledList.Item
            label="Total Clients"
            labelColor="#4287f5"
            color="#4287f5"
          >
            {data.total_clients}
          </LabeledList.Item>
          <LabeledList.Item
            label="Living Players"
            labelColor="#1d9123"
            color="#1d9123"
          >
            {data.living_players}
          </LabeledList.Item>
          <LabeledList.Item
            label="Dead Players"
            labelColor="#666e66"
            color="#666e66"
          >
            {data.dead_players}
          </LabeledList.Item>
          <LabeledList.Item
            label="Observers"
            labelColor="#34949e"
            color="#34949e"
          >
            {data.observers}
          </LabeledList.Item>
          <LabeledList.Item
            label="Living Antags"
            labelColor="#bd2924"
            color="#bd2924"
          >
            {data.living_antags}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Window>
  );
};
