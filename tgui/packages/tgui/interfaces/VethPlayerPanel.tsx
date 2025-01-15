import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Table, TextArea, Grid } from '../components';
import { Window } from '../layouts';

type PlayerData = {
  name: string;
  job: string;
  ckey: string;
  is_antagonist: boolean;
  last_ip: string;
  ref: string;
};

export const VethPlayerPanel = (_props) => {
  const { data, act } = useBackend<{ Data: PlayerData[] }>();
  const playerData = data?.Data || [];

  const [searchTerm, setSearchTerm] = useLocalState('searchTerm', '');
  const [selectedPlayerCkey, setSelectedPlayerCkey] = useLocalState(
    'selectedPlayerCkey',
    '',
  );
  // Filter player data based on the search term
  const filteredData = searchTerm
    ? playerData.filter((player) =>
        [
          player.name?.toLowerCase() || '',
          player.job?.toLowerCase() || '',
          player.ckey?.toLowerCase() || '',
        ].some((field) => field.includes(searchTerm.toLowerCase())),
      )
    : playerData;

  const handleAction = (action: string, params?: Record<string, any>) => {
    // If params has a ckey, set it as the selected ckey
    if (params?.ckey) {
      setSelectedPlayerCkey(params.ckey); // Fixed: Use params.ckey instead of PlayerData.ckey
    }

    // Send the action to the backend with the selected ckey
    act(action, {
      ...params,
      selectedPlayerCkey: params?.ckey || selectedPlayerCkey,
    });
  };
  return (
    <Box>
      <Window title="Player Panel Veth" width={1000} height={640}>
        <Window.Content>
          <Section>
            <Button
              icon="refresh"
              content="Refresh"
              onClick={() => handleAction('refresh')}
            />
            <Button content="Old PP" onClick={() => handleAction('oldPP')} />
            <Button
              content="Check Players"
              onClick={() => handleAction('checkPlayers')}
            />
            <Button
              content="Check Antags"
              onClick={() => handleAction('checkAntags')}
            />
            <Button
              content="Fax Panel"
              onClick={() => handleAction('faxPanel')}
            />
            <Button
              content="Game Panel"
              onClick={() => handleAction('gamePanel')}
            />
            <Button
              content="Combo HUD"
              onClick={() => handleAction('comboHUD')}
            />
            <Button
              content="Admin VOX"
              onClick={() => handleAction('adminVOX')}
            />
            <Button
              content="Generate Code"
              onClick={() => handleAction('generateCode')}
            />
            <Button
              content="View Opfors"
              onClick={() => handleAction('viewOpfors')}
            />
          </Section>

          <Section title="Search Players">
            <TextArea
              autoFocus
              placeholder="Search by name, job, or ckey"
              value={searchTerm}
              onInput={(_, value) => setSearchTerm(value)}
              rows={1}
              height="2rem"
            />
          </Section>

          <Section title={`Players (${filteredData.length})`}>
            <Table>
              <Table.Row header>
                <Table.Cell>Ckey</Table.Cell>
                <Table.Cell>Char Name</Table.Cell>
                <Table.Cell>Job</Table.Cell>
                <Table.Cell>Antagonist</Table.Cell>
                <Table.Cell>Last IP</Table.Cell>
                <Table.Cell>Actions</Table.Cell>
              </Table.Row>
              {filteredData.map((player) => (
                <Table.Row key={player.ckey}>
                  <Table.Cell>{player.ckey}</Table.Cell>
                  <Table.Cell>{player.name}</Table.Cell>
                  <Table.Cell>{player.job}</Table.Cell>
                  <Table.Cell>
                    {player.is_antagonist ? (
                      <Box color="red">Yes</Box>
                    ) : (
                      <Box color="green">No</Box>
                    )}
                  </Table.Cell>
                  <Table.Cell>{player.last_ip}</Table.Cell>
                  <Table.Cell>
                    <Button
                      onClick={() =>
                        handleAction('sendPrivateMessage', {
                          ckey: player.ckey, // Use player.ckey instead of selectedPlayerCkey
                        })
                      }
                      content="PM"
                    />
                    <Button
                      onClick={() =>
                        handleAction('follow', {
                          ckey: player.ckey,
                        })
                      }
                      content="Follow"
                    />
                    <Button
                      onClick={() =>
                        handleAction('smite', {
                          ckey: player.ckey,
                        })
                      }
                      content="Smite"
                    />
                    <Button
                      onClick={() =>
                        handleAction('openAdditionalPanel', {
                          ckey: player.ckey,
                        })
                      }
                      content="PP"
                      icon="external-link"
                    />
                    <Button
                      icon="book"
                      content="Logs"
                      onClick={() =>
                        act('logs', { selectedPlayerCkey: player.ckey })
                      }
                    />
                    <Button
                      icon="clipboard"
                      content="Notes"
                      onClick={() =>
                        act('notes', { selectedPlayerCkey: player.ckey })
                      }
                    />
                    <Button
                      content="VV"
                      onClick={() =>
                        act('vv', { selectedPlayerCkey: player.ckey })
                      }
                    />
                    <Button
                      content="TP"
                      onClick={() =>
                        act('tp', { selectedPlayerCkey: player.ckey })
                      }
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Window.Content>
      </Window>
    </Box>
  );
};
