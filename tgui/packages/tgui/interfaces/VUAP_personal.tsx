import { useBackend } from '../backend';
import { Box, Button, Section, Table, Stack, Grid } from '../components';
import { Window } from '../layouts';
import { useLocalState } from '../backend';

type PlayerData = {
  characterName: string;
  ckey: string;
  ipAddress: string;
  CID: string;
  gameState: string;
  dbLink: string;
  byondVersion: string;
  mobType: string;
  relatedByCid: string;
  relatedByIp: string;
  firstSeen: string;
  accountRegistered: string;
  muteStates: {
    ic: boolean;
    ooc: boolean;
    pray: boolean;
    adminhelp: boolean;
    webreq: boolean;
    deadchat: boolean;
  };
};

interface BackendData {
  Data: PlayerData;
}

// Helper function to check mob type
const isMobType = (currentType: string, checkType: string): boolean => {
  const types = {
    ghost: ['ghost', 'dead', 'observer'],
    human: ['human', 'carbon'],
    monkey: ['monkey', 'primate'],
    cyborg: ['cyborg', 'robot', 'borg'],
    ai: ['ai', 'artificial intelligence'],
  };
  return (
    types[checkType]?.some((type) =>
      currentType.toLowerCase().includes(type),
    ) || false
  );
};

export const VUAP_personal = () => {
  const { data, act } = useBackend<BackendData>();
  console.debug('VUAP Data:', data);

  const playerData = {
    characterName: data?.Data?.characterName || 'Unknown',
    ckey: data?.Data?.ckey || 'Unknown',
    ipAddress: data?.Data?.ipAddress || 'Unknown',
    CID: data?.Data?.CID || 'Unknown',
    gameState: data?.Data?.gameState || 'Unknown',
    dbLink: data?.Data?.dbLink || '',
    byondVersion: data?.Data?.byondVersion || 'Unknown',
    mobType: data?.Data?.mobType || 'Unknown',
    relatedByCid: data?.Data?.relatedByCid || '',
    relatedByIp: data?.Data?.relatedByIp || '',
    firstSeen: data?.Data?.firstSeen || 'Unknown',
    accountRegistered: data?.Data?.accountRegistered || 'Unknown',
    muteStates: data?.Data?.muteStates || {
      ic: false,
      ooc: false,
      pray: false,
      adminhelp: false,
      webreq: false,
      deadchat: false,
    },
  };
  const handleAction = (action: string) => {
    act(action, { selectedPlayerCkey });
  };

  const toggleMute = (type: string) => {
    act('toggleMute', { type });
  };

  const toggleAllMutes = () => {
    act('toggleAllMutes');
  };
  const handleRefresh = () => {
    act('refresh');
  };

  return (
    <Window
      title={`Options Panel - ${playerData.characterName}`}
      width={800}
      height={700}
    >
      <Window.Content>
        <Stack horizontal justify="flex-end">
          <Button icon="sync" content="Refresh" onclick={handleRefresh} />
        </Stack>
        <Stack vertical>
          <Section title="Player Information">
            <Table>
              <Table.Row>
                <Table.Cell bold>Character:</Table.Cell>
                <Table.Cell>{playerData.characterName}</Table.Cell>
                <Table.Cell bold>Ckey:</Table.Cell>
                <Table.Cell>{playerData.ckey}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell bold>IP Address:</Table.Cell>
                <Table.Cell>{playerData.ipAddress}</Table.Cell>
                <Table.Cell bold>Game State:</Table.Cell>
                <Table.Cell>{playerData.gameState}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell bold>DB Link:</Table.Cell>
                <Table.Cell>{playerData.dbLink}</Table.Cell>
                <Table.Cell bold>Byond Version:</Table.Cell>
                <Table.Cell>{playerData.byondVersion}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell bold>Mob Type:</Table.Cell>
                <Table.Cell>{playerData.mobType}</Table.Cell>
                <Table.Cell bold>CID:</Table.Cell>
                <Table.Cell>{playerData.CID}</Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell bold>First Seen:</Table.Cell>
                <Table.Cell>{playerData.firstSeen}</Table.Cell>
                <Table.Cell bold>Account Registered:</Table.Cell>
                <Table.Cell>{playerData.accountRegistered}</Table.Cell>
              </Table.Row>
            </Table>
          </Section>

          <Box>
            <Grid>
              <Grid.Column>
                <Section title="Punish">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="times"
                        content="KICK"
                        color="red"
                        onClick={() => handleAction('kick')}
                      />
                      <Button
                        fluid
                        icon="ban"
                        content="BAN"
                        color="red"
                        onClick={() => handleAction('ban')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="jail"
                        content="PRISON"
                        color="red"
                        onClick={() => handleAction('prison')}
                      />
                      <Button
                        fluid
                        icon="bolt"
                        content="SMITE"
                        color="red"
                        onClick={() => handleAction('smite')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
              <Grid.Column>
                <Section title="Message">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="comment"
                        content="PM"
                        onClick={() => handleAction('pm')}
                      />
                      <Button
                        fluid
                        icon="user-secret"
                        content="SM"
                        onClick={() => handleAction('sm')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="comment-alt"
                        content="NARRATE"
                        onClick={() => handleAction('narrate')}
                      />
                      <Button
                        fluid
                        icon="music"
                        content="PLAY SOUND TO"
                        onClick={() => handleAction('playsoundto')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>
            <Grid>
              <Grid.Column>
                <Section title="Movement">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="running"
                        content="JUMPTO"
                        onClick={() => handleAction('jumpto')}
                      />
                      <Button
                        fluid
                        icon="download"
                        content="GET"
                        onClick={() => handleAction('get')}
                      />
                      <Button
                        fluid
                        icon="paper-plane"
                        content="SEND"
                        onClick={() => handleAction('send')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="sign-out-alt"
                        content="LOBBY"
                        onClick={() => handleAction('lobby')}
                      />
                      <Button
                        fluid
                        icon="eye"
                        content="FLW"
                        onClick={() => handleAction('flw')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
              <Grid.Column>
                <Section title="Info">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="code"
                        content="VV"
                        onClick={() => handleAction('vv')}
                      />
                      <Button
                        fluid
                        icon="user-secret"
                        content="Traitor Panel"
                        onClick={() => handleAction('tp')}
                      />
                      <Button
                        fluid
                        icon="brain"
                        content="SKILLS"
                        onClick={() => handleAction('skills')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="book"
                        content="LOGS"
                        onClick={() => handleAction('logs')}
                      />
                      <Button
                        fluid
                        icon="clipboard"
                        content="NOTES"
                        onClick={() => handleAction('notes')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>
            <Grid>
              <Grid.Column>
                <Section title="Transformation">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="ghost"
                        content="MAKE GHOST"
                        color={
                          isMobType(playerData.mobType, 'ghost') ? 'good' : ''
                        }
                        onClick={() => handleAction('makeghost')}
                      />
                      <Button
                        fluid
                        icon="user"
                        content="MAKE HUMAN"
                        color={
                          isMobType(playerData.mobType, 'human') ? 'good' : ''
                        }
                        onClick={() => handleAction('makehuman')}
                      />
                      <Button
                        fluid
                        icon="paw"
                        content="MAKE MONKEY"
                        color={
                          isMobType(playerData.mobType, 'monkey') ? 'good' : ''
                        }
                        onClick={() => handleAction('makemonkey')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="robot"
                        content="MAKE CYBORG"
                        color={
                          isMobType(playerData.mobType, 'cyborg') ? 'good' : ''
                        }
                        onClick={() => handleAction('makeborg')}
                      />
                      <Button
                        fluid
                        icon="microchip"
                        content="MAKE AI"
                        color={
                          isMobType(playerData.mobType, 'ai') ? 'good' : ''
                        }
                        onClick={() => handleAction('makeai')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
              <Grid.Column>
                <Section title="Misc">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="language"
                        content="LANGUAGE"
                        onClick={() => handleAction('language')}
                      />
                      <Button
                        fluid
                        icon="comment"
                        content="FORCESAY"
                        onClick={() => handleAction('forcesay')}
                      />
                      <Button
                        fluid
                        icon="user-edit"
                        content="APPLY CLIENT QUIRKS"
                        onClick={() => handleAction('applyquirks')}
                      />
                      <Button
                        fluid
                        icon="gavel"
                        content="THUNDERDOME 1"
                        onClick={() => handleAction('thunderdome1')}
                      />
                      <Button
                        fluid
                        icon="gavel"
                        content="THUNDERDOME 2"
                        onClick={() => handleAction('thunderdome2')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="star"
                        content="COMMEND"
                        onClick={() => handleAction('commend')}
                      />
                      <Button
                        fluid
                        icon="eye"
                        content="PLAYTIME"
                        onClick={() => handleAction('playtime')}
                      />
                      <Button
                        fluid
                        icon="gavel"
                        content="THUNDERDOME ADMIN"
                        onClick={() => handleAction('thunderdomeadmin')}
                      />
                      <Button
                        fluid
                        icon="eye"
                        content="THUNDERDOME OBSERVER"
                        onClick={() => handleAction('thunderdomeobserver')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>
            <Grid>
              <Grid.Column>
                <Section title="Mute Controls">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button.Checkbox
                        fluid
                        checked={!!playerData.muteStates?.ic}
                        onClick={() => toggleMute('ic')}
                        content="IC"
                        color={playerData.muteStates?.ic ? 'red' : 'green'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={!!playerData.muteStates?.ooc}
                        onClick={() => toggleMute('ooc')}
                        content="OOC"
                        color={playerData.muteStates?.ooc ? 'red' : 'green'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={!!playerData.muteStates?.pray}
                        onClick={() => toggleMute('pray')}
                        content="PRAY"
                        color={playerData.muteStates?.pray ? 'red' : 'green'}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button.Checkbox
                        fluid
                        checked={!!playerData.muteStates?.adminhelp}
                        onClick={() => toggleMute('adminhelp')}
                        content="ADMINHELP"
                        color={
                          playerData.muteStates?.adminhelp ? 'red' : 'green'
                        }
                      />
                      <Button.Checkbox
                        fluid
                        checked={!!playerData.muteStates?.webreq}
                        onClick={() => toggleMute('webreq')}
                        content="WEBREQ"
                        color={playerData.muteStates?.webreq ? 'red' : 'green'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={!!playerData.muteStates?.deadchat}
                        onClick={() => toggleMute('deadchat')}
                        content="DEADCHAT"
                        color={
                          playerData.muteStates?.deadchat ? 'red' : 'green'
                        }
                      />
                      <Button
                        fluid
                        content="Toggle All"
                        onClick={toggleAllMutes}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>
          </Box>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export default VUAP_personal;
