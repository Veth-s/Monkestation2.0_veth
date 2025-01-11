import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Table, TextArea, Grid } from '../components';
import { Window } from '../layouts';
import { MessageModal } from './VethPlayerPanel/MessageModal';
import { ModalBackdrop } from './VethPlayerPanel/ModalBackdrop';

type PlayerData = {
  name: string;
  job: string;
  ckey: string;
  is_antagonist: boolean;
  last_ip: string;
  ref: string;
};

export const VethPlayerPanel = (_props, context) => {
  const { data, act } = useBackend<{ Data: PlayerData[] }>(context);
  const playerData = data?.Data || [];

  const [searchTerm, setSearchTerm] = useLocalState('searchTerm', '');
  const [isModalOpen, setIsModalOpen] = useLocalState('isModalOpen', false);
  const [selectedPlayerCkey, setSelectedPlayerCkey] = useLocalState(
    'selectedPlayerCkey',
    '',
  );
  const [inputMessage, setInputMessage] = useLocalState('inputMessage', '');

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

  // Function to open the message modal
  const openMessageModal = (ckey: string) => {
    setSelectedPlayerCkey(ckey);
    setInputMessage('');
    setIsModalOpen(true);
  };

  // Function to close the message modal
  const closeMessageModal = () => {
    setIsModalOpen(false);
  };

  // Function to send private message
  const handleSendPrivateMessage = () => {
    if (inputMessage.trim()) {
      act('sendPrivateMessage', {
        selectedPlayerCkey: selectedPlayerCkey,
        inputMessage: inputMessage,
      });
      setInputMessage('');
    }
    closeMessageModal();
  };

  const handleRefresh = () => {
    act('refresh');
  };

  const handleFollow = (ckey: string) => {
    setSelectedPlayerCkey(ckey);
    act('follow', { selectedPlayerCkey: ckey });
  };

  const handleSmite = (ckey: string) => {
    setSelectedPlayerCkey(ckey);
    act('smite', { selectedPlayerCkey: ckey });
  };

  const handleOldPP = () => act('oldPP');
  const handleCheckPlayers = () => act('checkPlayers');
  const handleCheckAntags = () => act('checkAntags');
  const handleFax = () => act('faxPanel');
  const handleGamePanel = () => act('gamePanel');
  const handleComboHUD = () => act('comboHUD');
  const handleAdminVOX = () => act('adminVOX');
  const handleGenerateCode = () => act('generateCode');
  const handleViewOpfors = () => act('viewOpfors');

  // Fixed additional panel function
  const handleAdditionalPanel = (ckey: string) => {
    setSelectedPlayerCkey(ckey);
    act('openAdditionalPanel', { selectedPlayerCkey: ckey });
  };

  return (
    <Box>
      <Window title="Player Panel Veth" width={1000} height={640}>
        <Window.Content>
          <Section>
            <Button icon="refresh" content="Refresh" onClick={handleRefresh} />
          </Section>

          <Section>
            <Grid>
              <Grid.Column>
                <Box>
                  <Grid>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="users"
                        content="Check Players"
                        onClick={handleCheckPlayers}
                      />
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="user"
                        content="PP(old)"
                        onClick={handleOldPP}
                      />
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="exclamation"
                        content="Check Antags"
                        onClick={handleCheckAntags}
                      />
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="file"
                        content="Fax"
                        onClick={handleFax}
                      />
                    </Grid.Column>
                  </Grid>
                </Box>
                <Box mt={1}>
                  <Grid>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="cog"
                        content="Game Panel"
                        onClick={handleGamePanel}
                      />
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="info-circle"
                        content="ComboHUD"
                        onClick={handleComboHUD}
                      />
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="heart"
                        content="VOX"
                        onClick={handleAdminVOX}
                      />
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="reply"
                        content="Codegen"
                        onClick={handleGenerateCode}
                      />
                    </Grid.Column>
                  </Grid>
                </Box>
                <Box mt={1}>
                  <Grid>
                    <Grid.Column size={3}>
                      <Button
                        fluid
                        icon="camera"
                        content="View Opfors"
                        onClick={handleViewOpfors}
                      />
                    </Grid.Column>
                  </Grid>
                </Box>
              </Grid.Column>
            </Grid>
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
                      icon="message"
                      content="PM"
                      onClick={() => openMessageModal(player.ckey)}
                    />
                    <Button
                      icon="eye"
                      content="Follow"
                      onClick={() => handleFollow(player.ckey)}
                    />
                    <Button
                      icon="trash"
                      content="Smite"
                      onClick={() => handleSmite(player.ckey)}
                    />
                    <Button
                      icon="external-link-alt"
                      content="PP"
                      onClick={() => handleAdditionalPanel(player.ckey)}
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Window.Content>
      </Window>

      {isModalOpen && (
        <>
          <ModalBackdrop />
          <MessageModal
            selectedPlayerCkey={selectedPlayerCkey}
            inputMessage={inputMessage}
            onInputMessageChange={setInputMessage}
            onSendPrivateMessage={handleSendPrivateMessage}
            onClose={closeMessageModal}
          />
        </>
      )}
    </Box>
  );
};
