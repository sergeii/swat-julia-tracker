class Extension extends Julia.Extension
  implements Julia.InterestedInMissionEnded,
             HTTP.ClientOwner;

/**
 * Copyright (c) 2014-2015 Sergei Khoroshilov <kh.sergei@gmail.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import enum Pocket from Engine.HandheldEquipment;
import enum ObjectiveStatus from SwatGame.Objective;
import enum eClientError from HTTP.Client;

/**
 * A character (or a sequence of characters) used to delimit keys in m-dimensional constructions
 * 
 * For instance, the key "foo.bar.ham.42" is equivalent to the foo[bar][ham][42] URI array syntax.
 * The dot notation is much more efficient since a dot occupies only a byte 
 * in comparison to 6 bytes for a pair of urlencoded brackets
 * @type string
 */
const KEY_DELIMITER = ".";

/**
 * Length of a random request id
 * @type int
 */
const REQUEST_ID_LENGTH = 8;


enum eRootKey
{
    RK_REQUEST_ID,          /* 0 Unique REQUEST_ID_LENGTH-long request id */
    RK_VERSION,             /* 1 Version of the tracker extension */
    RK_PORT,                /* 2 Join port */
    RK_TIMESTAMP,           /* 3 Current unix timestamp */
    RK_HASH,                /* 4 Server hash signature */

    RK_GAME_TITLE,          /* 5 Game title (SWAT 4/SWAT 4 X, encoded) Default 0 */
    RK_GAME_VERSION,        /* 6 Game version 1.0, 1.1, etc */

    RK_HOSTNAME,            /* 7 Server name */
    RK_GAMETYPE,            /* 8 Gametype (encoded) Default 0 */
    RK_MAP,                 /* 9 Map (encoded) Default 0 */
    RK_PASSWORDED,          /* 10 Password protection Default 0 */

    RK_PLAYER_COUNT,        /* 11 Current player count */
    RK_PLAYER_LIMIT,        /* 12 Player limit */

    RK_ROUND_INDEX,         /* 13 Current round index Default 0*/
    RK_ROUND_LIMIT,         /* 14 Rounds per map limit */

    RK_TIME_ABSOLUTE,       /* 15 Time elapsed since the round start */
    RK_TIME_PLAYED,         /* 16 Game time */
    RK_TIME_LIMIT,          /* 17 Game time limit */

    RK_SWAT_ROUNDS,         /* 18 SWAT victories Default 0 */
    RK_SUS_ROUNDS,          /* 19 Suspects victories Default 0*/

    RK_SWAT_SCORE,          /* 20 SWAT score Default 0 */
    RK_SUS_SCORE,           /* 21 Suspects score Default 0*/

    RK_OUTCOME,             /* 22 Round outcome (encoded) */

    RK_BOMBS_DEFUSED,       /* 23 Number of bombs defused Default 0 */
    RK_BOMBS_TOTAL,         /* 24 Total number of bombs Default 0 */

    RK_OBJECTIVES,          /* 25 List of COOP objectives */
    RK_PROCEDURES,          /* 26 List of COOP procedures */

    RK_PLAYERS,             /* 27 List of all players participated in the game */
};

enum ePlayerKey
{
    PK_ID,                  /* 0 */
    PK_IP,                  /* 1 */

    PK_DROPPED,             /* 2 */
    PK_ADMIN,               /* 3 */
    PK_VIP,                 /* 4 */

    PK_NAME,                /* 5 */
    PK_TEAM,                /* 6 */
    PK_TIME,                /* 7 */

    PK_SCORE,               /* 8 */
    PK_KILLS,               /* 9 */
    PK_TEAM_KILLS,          /* 10 */
    PK_DEATHS,              /* 11 */
    PK_SUICIDES,            /* 12 */
    PK_ARRESTS,             /* 13 */
    PK_ARRESTED,            /* 14 */

    PK_KILL_STREAK,         /* 15 */
    PK_ARREST_STREAK,       /* 16 */
    PK_DEATH_STREAK,        /* 17 */

    PK_VIP_CAPTURES,        /* 18 */
    PK_VIP_RESCUES,         /* 19 */
    PK_VIP_ESCAPES,         /* 20 */
    PK_VIP_KILLS_VALID,     /* 21 */
    PK_VIP_KILLS_INVALID,   /* 22 */

    PK_BOMBS_DEFUSED,       /* 23 */
    PK_RD_CRYBABY,          /* 24 */

    PK_CASE_KILLS,          /* 25 */
    PK_CASE_ESCAPES,        /* 26 */
    PK_SG_CRYBABY,          /* 27 */

    PK_HOSTAGE_ARRESTS,     /* 28 */
    PK_HOSTAGE_HITS,        /* 29 */
    PK_HOSTAGE_INCAPS,      /* 30 */
    PK_HOSTAGE_KILLS,       /* 31 */
    PK_ENEMY_ARRESTS,       /* 32 */
    PK_ENEMY_INCAPS,        /* 33 */
    PK_ENEMY_KILLS,         /* 34 */
    PK_ENEMY_INCAPS_INVALID,/* 35 */
    PK_ENEMY_KILLS_INVALID, /* 36 */
    PK_TOC_REPORTS,         /* 37 */
    PK_COOP_STATUS,         /* 38 */

    PK_LOADOUT,             /* 39 */
    PK_WEAPONS,             /* 40 */
};

enum eWeaponKey
{
    WK_NAME,            /* 0 Weapon name (encoded) */
    WK_TIME,            /* 1 Time used Default 0 */
    WK_SHOTS,           /* 2 Bullets fired Default 0*/
    WK_HITS,            /* 3 Enemies hit Default 0 */
    WK_TEAM_HITS,       /* 4 Team mates hit Default 0 */
    WK_KILLS,           /* 5 Enemies killed Default 0 */
    WK_TEAM_KILLS,      /* 6 Team mates killed Default 0 */
    WK_KILL_DISTANCE,   /* 7 Best kill distance Default 0 */
};

enum eObjectiveKey
{
    OBJ_NAME,           /* 0 Objective name (encoded) */
    OBJ_STATUS,         /* 1 Objective status Default 1 */
};

enum eProcedureKey
{
    PRO_NAME,           /* 0 Procedure name (encoded) */
    PRO_STATUS,         /* 1 Procedure status x/y Default 0 */
    PRO_VALUE,          /* 2 Procedure score Default 0 */
};

/**
 * HTTP client instance used to stream data through
 * @type class'HTTP.Client'
 */
var protected HTTP.Client Client;

/**
 * List of trackers
 * @type array<string>
 */
var config array<string> URL;

/**
 * Indicate whether any sort of tracker messages should appear in admin chat
 * @type bool
 */
var config bool Feedback;

/**
 * Limit the number of HTTP request attempts
 * @type int
 */
var config int Attempts;

/**
 * Unique server key
 * @type string
 */
var config string Key;

/**
 * Indicate whether query string keys should be constructed using the URI array syntax
 * @type bool
 */
var config bool Compatible;

/**
 * Destroy the instance if no tracker url or server key has been supplied
 * 
 * @return  void
 */
public function PreBeginPlay()
{
    Super.PreBeginPlay();

    self.Attempts = Max(1, self.Attempts);

    if (self.URL.Length == 0)
    {
        log(self $ ": no tracker URL has been supplied");
    }
    else if (self.Key == "")
    {
        log(self $ ": empty Key value");
    }
    else
    {
        return;
    }

    self.Destroy();
}

/**
 * @return  void
 */
public function BeginPlay()
{
    Super.BeginPlay();
    self.Core.RegisterInterestedInMissionEnded(self);
    self.Client = Spawn(class'HTTP.Client');
}

/**
 * Send midgame stats upon a round end
 * 
 * @return  void
 */
public function OnMissionEnded()
{
    local HTTP.Message Request;

    Request = Spawn(class'HTTP.Message');

    self.InitRequest(Request);
    self.AddServerDetails(Request);
    self.AddPlayerDetails(Request);
    self.PushRequest(Request);

    Request.Destroy();
}

/**
 * @see HTTP.ClientOwner.OnRequestSuccess
 */
public function OnRequestSuccess(int StatusCode, string Response, string Hostname, int Port)
{
    local array<string> Lines;
    local string Status, Message, StatusMessage;

    if (StatusCode == 200)
    {
        Lines = class'Utils.StringUtils'.static.Part(Response, "\n");

        Status = Lines[0];
        Lines.Remove(0, 1);

        // Limit the message length
        Message = Left(
            class'Utils.StringUtils'.static.Strip(class'Utils.ArrayUtils'.static.Join(Lines, "\n")), 512
        );
        StatusMessage = self.Locale.Translate("SuccessMessage");

        switch (Status)
        {
            case "1":
                StatusMessage = self.Locale.Translate("WarningMessage");
                // no break
            case "0":
                
                // Display a warning/notification
                if (Message != "")
                {
                    self.DisplayMessage(class'Utils.StringUtils'.static.Format(StatusMessage, Hostname, Message));
                }
                return;

            default:
                break;
        }
    }

    log(self $ ": received " $ Left(Response, 20) $ " from " $ Hostname $ "(" $ StatusCode $ ")");

    // Display an error message 
    self.DisplayMessage(
        self.Locale.Translate("WarningMessage", Hostname, self.Locale.Translate("ResponseErrorMessage"))
    );
}

/**
 * @see HTTP.ClientOwner.OnRequestFailure
 */
public function OnRequestFailure(eClientError ErrorCode, string ErrorMessage, string Hostname, int Port)
{
    log(self $ ": failed to send data to " $ Hostname $ " (" $ ErrorMessage $ ")");
    self.DisplayMessage(
        self.Locale.Translate("WarningMessage", Hostname, self.Locale.Translate("HostFailureMessage"))
    );
}

/**
 * Append request specific details to Request instance
 *
 * @param   class'HTTP.Message' Request
 * @return  void
 */
protected function InitRequest(HTTP.Message Request)
{
    local int Port, Timestamp;

    Port = SwatGameInfo(Level.Game).GetServerPort();
    Timestamp = class'Utils.LevelUtils'.static.Timestamp(Level);

    // Generate a random key
    self.AddRequestItem(
        Request, class'Utils.StringUtils'.static.Random(class'Extension'.const.REQUEST_ID_LENGTH, ":alnum:"), "", eRootKey.RK_REQUEST_ID
    );
    // Extension version
    self.AddRequestItem(Request, self.Version, "", eRootKey.RK_VERSION);
    // Server join port
    self.AddRequestItem(Request, Port, "", eRootKey.RK_PORT);
    // Timestamp
    self.AddRequestItem(Request, Timestamp, "", eRootKey.RK_TIMESTAMP);
    // Unique hash
    self.AddRequestItem(Request, class'Utils'.static.ComputeHash(self.Key, Port, Timestamp), "", eRootKey.RK_HASH);
}

/**
 * Append server details to request Request
 *
 * @param   class'HTTP.Message' Request
 * @return  void
 */
protected function AddServerDetails(HTTP.Message Request)
{
    local Julia.Server Server;

    Server = self.Core.GetServer();

    // 0-SWAT 4/ 1-SWAT 4X (default 0)
    self.AddRequestItem(Request, int(Server.GetGame() == "SWAT 4X"), "0", eRootKey.RK_GAME_TITLE);
    // Game version
    self.AddRequestItem(Request, Server.GetGameVer(), "", eRootKey.RK_GAME_VERSION);
    // Server name
    self.AddRequestItem(Request, Server.GetHostname(), "", eRootKey.RK_HOSTNAME);
    // Game mode (encoded, default 0)
    self.AddRequestItem(Request, Server.GetGameType(), "0", eRootKey.RK_GAMETYPE);
    // Map name (encoded, default 0)
    self.AddRequestItem(
        Request, class'Utils'.static.EncodeString(Server.GetMap(), class'Julia.Utils'.default.MapTitle), "0", eRootKey.RK_MAP
    );
    // Indicate whether the server is password protected (default 0)
    self.AddRequestItem(Request, int(Server.IsPassworded()), "0", eRootKey.RK_PASSWORDED);
    // Current number of players on the server
    self.AddRequestItem(Request, Server.GetPlayerCount(), "", eRootKey.RK_PLAYER_COUNT);
    // Number of player slots
    self.AddRequestItem(Request, Server.GetPlayerLimit(), "", eRootKey.RK_PLAYER_LIMIT);
    // Current zero based round number (default 0)
    self.AddRequestItem(Request, Server.GetRoundIndex(), "0", eRootKey.RK_ROUND_INDEX);
    // Rounds per map
    self.AddRequestItem(Request, Server.GetRoundLimit(), "", eRootKey.RK_ROUND_LIMIT);
    // Time elapsed since the round start
    self.AddRequestItem(Request, int(Server.GetTimeTotal()), "", eRootKey.RK_TIME_ABSOLUTE);
    // Time spent playing
    self.AddRequestItem(Request, int(Server.GetTimePlayed()), "", eRootKey.RK_TIME_PLAYED);
    // Round time limit
    self.AddRequestItem(Request, Server.GetRoundTimeLimit(), "", eRootKey.RK_TIME_LIMIT);
    // Rounds won by SWAT
    self.AddRequestItem(Request, Server.GetSwatVictories(), "0", eRootKey.RK_SWAT_ROUNDS);
    // Rounds won by suspects
    self.AddRequestItem(Request, Server.GetSuspectsVictories(), "0", eRootKey.RK_SUS_ROUNDS);
    // SWAT score
    self.AddRequestItem(Request, Server.GetSwatScore(), "0", eRootKey.RK_SWAT_SCORE);
    // Suspects score
    self.AddRequestItem(Request, Server.GetSuspectsScore(), "0", eRootKey.RK_SUS_SCORE);
    // Round outcome
    self.AddRequestItem(Request, Server.GetOutcome(), "", eRootKey.RK_OUTCOME);
    // Bomb stats
    if (Server.GetGameType() == MPM_RapidDeployment)
    {
        // Number of bombs defused by SWAT
        self.AddRequestItem(Request, Server.GetBombsDefused(), "0", eRootKey.RK_BOMBS_DEFUSED);
        // Total number of bombs (both disarmed and detonated)
        self.AddRequestItem(Request, Server.GetBombsTotal(), "0", eRootKey.RK_BOMBS_TOTAL);
    }
    // COOP objectives + procedures
    else if (Server.IsCOOP())
    {
        self.AddCOOPObjectives(Request);
        self.AddCOOPProcedures(Request);
    }
}

/**
 * Append list of current COOP objectives
 *
 * @param   class'HTTP.Message' Request
 * @return  void
 */
protected function AddCOOPObjectives(HTTP.Message Request)
{
    local int i, j;
    local MissionObjectives Objectives;
    local string Name;
    local ObjectiveStatus Status;

    Objectives = SwatRepo(Level.GetRepo()).MissionObjectives;

    for (i = 0; i < Objectives.Objectives.Length; i++)
    {
        if (Objectives.Objectives[i].name == 'Automatic_DoNot_Die')
        {
            continue;
        }

        Name = class'Utils'.static.EncodeString(Objectives.Objectives[i].name, class'Utils'.default.ObjectiveClass);
        Status = SwatGameReplicationInfo(Level.Game.GameReplicationInfo).ObjectiveStatus[i];

        // Objective name (encoded)
        self.AddRequestItem(Request, Name, "", eRootKey.RK_OBJECTIVES, j, eObjectiveKey.OBJ_NAME);
        // Objective status (default 1)
        self.AddRequestItem(Request, Status, "1", eRootKey.RK_OBJECTIVES, j, eObjectiveKey.OBJ_STATUS);
        j++;
    }
}

/**
 * Append list of current COOP procudures
 *
 * @param   class'HTTP.Message' Request
 * @return  void
 */
protected function AddCOOPProcedures(HTTP.Message Request)
{
    local int i;
    local Procedures Procedures;
    local string Name;

    Procedures = SwatRepo(Level.GetRepo()).Procedures;

    for (i = 0; i < Procedures.Procedures.Length; i++)
    {
        Name = class'Utils'.static.EncodeString(
            Procedures.Procedures[i].class.name, class'Utils'.default.ProcedureClass
        );
        // Procedure name (encoded)
        self.AddRequestItem(
            Request, Name, "", eRootKey.RK_PROCEDURES, i, eProcedureKey.PRO_NAME
        );
        // Procedure status x/y (Default 0)
        self.AddRequestItem(
            Request, Procedures.Procedures[i].Status(), "0", eRootKey.RK_PROCEDURES, i, eProcedureKey.PRO_STATUS
        );
        // Procedure score (e.g. 40 for mission completed) (Default 0)
        self.AddRequestItem(
            Request, Procedures.Procedures[i].GetCurrentValue(), "0", eRootKey.RK_PROCEDURES, i, eProcedureKey.PRO_VALUE
        );
    }
}

/**
 * Append list of current COOP procudures
 *
 * @param   class'HTTP.Message' Request
 * @return  void
 */
protected function AddPlayerDetails(HTTP.Message Request)
{
    local int i, j, k;
    local array<Julia.Player> Players;
    local array<Julia.Weapon> Weapons;
    local DynamicLoadoutSpec Loadout;
    local string WeaponName, PocketEncoded;

    Players = self.Core.GetServer().GetPlayers();

    for (i = 0; i < Players.Length; i++)
    {
        // Instance has been created, but not filled with actual data (rare)
        if (Players[i].GetLastTeam() == -1)
        {
            // Skip the player
            continue;
        }
        // Player ID
        self.AddRequestItem(Request, i, "", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ID);
        // IP address
        self.AddRequestItem(Request, Players[i].GetIPAddr(), "", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_IP);
        // Has the player left the server? (default 0)
        self.AddRequestItem(Request, int(Players[i].WasDropped()), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_DROPPED);
        // Is the player an admin? (default 0)
        self.AddRequestItem(Request, int(Players[i].WasAdmin()), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ADMIN);
        // Is the player the VIP? (default 0)
        self.AddRequestItem(Request, int(Players[i].WasVIP()), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_VIP);
        // Player name
        self.AddRequestItem(Request, Players[i].GetLastName(), "", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_NAME);
        // Team (default 0)
        self.AddRequestItem(Request, Players[i].GetLastTeam(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_TEAM);
        // Time played (default 0)
        self.AddRequestItem(Request, int(Players[i].GetTimePlayed()), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_TIME);
        // Score (default 0)
        self.AddRequestItem(Request, Players[i].GetLastScore(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_SCORE);
        // Kills (default 0)
        self.AddRequestItem(Request, Players[i].GetLastKills(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_KILLS);
        // Team kills (default 0)
        self.AddRequestItem(Request, Players[i].GetLastTeamKills(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_TEAM_KILLS);
        // Deaths (default 0)
        self.AddRequestItem(Request, Players[i].GetLastDeaths(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_DEATHS);
        // Suicides (default 0)
        self.AddRequestItem(Request, Players[i].GetSuicides(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_SUICIDES);
        // Arrests (default 0)
        self.AddRequestItem(Request, Players[i].GetLastArrests(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ARRESTS);
        // Times arrested (default 0)
        self.AddRequestItem(Request, Players[i].GetLastArrested(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ARRESTED);
        // Best kill streak (default 0)
        self.AddRequestItem(Request, Players[i].GetBestKillStreak(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_KILL_STREAK);
        // Best arrest streak (default 0)
        self.AddRequestItem(Request, Players[i].GetBestArrestStreak(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ARREST_STREAK);
        // "Best" death streak (default 0)
        self.AddRequestItem(Request, Players[i].GetBestDeathStreak(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_DEATH_STREAK);
        // Numer of VIP arrests (default 0)
        self.AddRequestItem(Request, Players[i].GetLastVIPCaptures(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_VIP_CAPTURES);
        // Numer of VIP rescues (default 0)
        self.AddRequestItem(Request, Players[i].GetLastVIPRescues(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_VIP_RESCUES);
        // Numer of VIP escapes (default 0)
        self.AddRequestItem(Request, Players[i].GetLastVIPEscapes(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_VIP_ESCAPES);
        // Numer of valid VIP kills (default 0)
        self.AddRequestItem(
            Request, Players[i].GetLastVIPKillsValid(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_VIP_KILLS_VALID
        );
        // Numer of invalid VIP kills (default 0)
        self.AddRequestItem(
            Request, Players[i].GetLastVIPKillsInvalid(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_VIP_KILLS_INVALID
        );
        // Numer of bombs defused (default 0)
        self.AddRequestItem(Request, Players[i].GetLastBombsDefused(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_BOMBS_DEFUSED);
        // RD crybaby (default 0)
        self.AddRequestItem(Request, Players[i].GetLastRDCryBaby(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_RD_CRYBABY);
        // Number of case carrier kills (default 0)
        self.AddRequestItem(Request, Players[i].GetLastSGKills(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_CASE_KILLS);
        // Number of case escapes (default 0)
        self.AddRequestItem(Request, Players[i].GetLastSGEscapes(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_CASE_ESCAPES);
        // SG crybaby (default 0)
        self.AddRequestItem(Request, Players[i].GetLastSGCryBaby(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_SG_CRYBABY);
        // Number of hostage arrests (default 0)
        self.AddRequestItem(
            Request, Players[i].GetCivilianArrests(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_HOSTAGE_ARRESTS
        );
        // Number of hostage hits (default 0)
        self.AddRequestItem(
            Request, Players[i].GetCivilianHits(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_HOSTAGE_HITS
        );
        // Number of hostage incaps (default 0)
        self.AddRequestItem(
            Request, Players[i].GetCivilianIncaps(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_HOSTAGE_INCAPS
        );
        // Number of hostage kills (default 0)
        self.AddRequestItem(
            Request, Players[i].GetCivilianKills(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_HOSTAGE_KILLS
        );
        // Number of suspect arrests (default 0)
        self.AddRequestItem(
            Request, Players[i].GetEnemyArrests(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ENEMY_ARRESTS
        );
        // Number of suspect incaps (default 0)
        self.AddRequestItem(
            Request, Players[i].GetEnemyIncaps(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ENEMY_INCAPS
        );
        // Number of suspect kills (default 0)
        self.AddRequestItem(
            Request, Players[i].GetEnemyKills(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ENEMY_KILLS
        );
        // Number of unauthorized suspect incaps (default 0)
        self.AddRequestItem(
            Request, Players[i].GetEnemyIncapsInvalid(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ENEMY_INCAPS_INVALID
        );
        // Number of unauthorized suspect kills (default 0)
        self.AddRequestItem(
            Request, Players[i].GetEnemyKillsInvalid(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_ENEMY_KILLS_INVALID
        );
        // Number of TOC reports (default 0)
        self.AddRequestItem(
            Request, Players[i].GetCharacterReports(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_TOC_REPORTS
        );
        // COOP status (default 0)
        self.AddRequestItem(
            Request, Players[i].GetLastCOOPStatus(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_COOP_STATUS
        );

        // Last used loadout
        Loadout = class'Extension'.static.GetPlayerLoadout(Players[i]);

        if (LoadOut != None)
        {
            for (j = 0; j <= Pocket.Pocket_HeadArmor; j++)
            {
                if (Loadout.LoadOutSpec[j] == None)
                {
                    continue;
                }
                switch (Pocket(j))
                {
                    // Encode ammo
                    case Pocket_PrimaryAmmo :
                    case Pocket_SecondaryAmmo :
                        PocketEncoded = class'Utils'.static.EncodeString(
                            Loadout.LoadOutSpec[j].Name, class'Utils'.default.AmmoClass 
                        );
                        break;
                    // Encode everything else
                    default:
                        PocketEncoded = class'Utils'.static.EncodeString(
                            Loadout.LoadOutSpec[j].Name, class'Julia.Utils'.default.EquipmentClass
                        );
                        break;
                }
                self.AddRequestItem(Request, PocketEncoded, "", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_LOADOUT, j);
            }
        }

        // Player weapons
        Weapons = Players[i].GetWeapons();

        for (j = 0; j < Weapons.Length; j++)
        {
            // Skip unused weapons
            if (Weapons[j].GetShots() == 0 && Weapons[j].GetTimeUsed() == 0)
            {
                continue;
            }

            WeaponName = class'Utils'.static.EncodeString(
                Weapons[j].GetClassName(), class'Julia.Utils'.default.EquipmentClass
            );
            // Weapon name (encoded)
            self.AddRequestItem(
                Request, WeaponName, "", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_WEAPONS, k, eWeaponKey.WK_NAME
            );
            // Weapon usage time (default 0)
            self.AddRequestItem(
                Request, int(Weapons[j].GetTimeUsed()), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_WEAPONS, k, eWeaponKey.WK_TIME
            );
            // Ammo fired (default 0)
            self.AddRequestItem(
                Request, Weapons[j].GetShots(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_WEAPONS, k, eWeaponKey.WK_SHOTS
            );
            // Enemy hits (default 0)
            self.AddRequestItem(
                Request, Weapons[j].GetHits(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_WEAPONS, k, eWeaponKey.WK_HITS
            );
            // Team hits (default 0)
            self.AddRequestItem(
                Request, Weapons[j].GetTeamHits(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_WEAPONS, k, eWeaponKey.WK_TEAM_HITS
            );
            // Enemy kills (default 0)
            self.AddRequestItem(
                Request, Weapons[j].GetKills(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_WEAPONS, k, eWeaponKey.WK_KILLS
            );
            // Team kills (default 0)
            self.AddRequestItem(
                Request, Weapons[j].GetTeamKills(), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_WEAPONS, k, eWeaponKey.WK_TEAM_KILLS
            );
            // Best kill distance (cm, default 0)
            self.AddRequestItem(
                Request, int(Weapons[j].GetBestKillDistance()), "0", eRootKey.RK_PLAYERS, i, ePlayerKey.PK_WEAPONS, k, eWeaponKey.WK_KILL_DISTANCE
            );
            k++;
        }
    }
}

/**
 * Send Request message through the client
 *
 * @param   class'HTTP.Message' Request
 * @return  void
 */
protected function PushRequest(HTTP.Message Request)
{
    local int i;

    for (i = 0; i < self.URL.Length; i++)
    {
        self.Client.Send(Request.Copy(), self.URL[i], 'POST', self, self.Attempts);
    }
}

/**
 * Display a message in admin chat
 * 
 * @param   string Message
 * @return  void
 */
protected function DisplayMessage(string Message)
{
    if (!self.Feedback)
    {
        return;
    }
    class'Utils.LevelUtils'.static.TellAdmins(Level, Message, None, self.Locale.Translate("MessageColor"));
}

/**
 * Add a querystring item to Request instance unless Value matches DefaultValue
 * If multiple keys provided, form up a complex key
 * 
 * @param   class'HTTP.Message' Request
 * @param   string Value
 * @param   string DefaultValue
 * @param   string Key1
 * @param   string Key2 (optional)
 * @param   string Key3 (optional)
 * @param   string Key4 (optional)
 * @param   string Key5 (optional)
 * @return  void
 */
protected function AddRequestItem(
    HTTP.Message Request, coerce string Value, coerce string DefaultValue, 
    coerce string Key1, 
    coerce optional string Key2, 
    coerce optional string Key3, 
    coerce optional string Key4, 
    coerce optional string Key5
)
{
    local string Key;
    // Skip items equal to the default value or items with empty value
    if (Value == "" || (DefaultValue != "" && Value == DefaultValue))
    {
        return;
    }
    // Construct a key in the form of foo[bar][ham]
    if (self.Compatible)
    {
        Key = class'Utils'.static.FormatArrayKey(Key1, Key2, Key3, Key4, Key5);
    }
    // Or use the efficient notation foo.bar.ham
    else
    {
        Key = class'Utils'.static.FormatDelimitedKey(Key1, Key2, Key3, Key4, Key5);
    }
    Request.AddQueryString(Key, Value);
}

/**
 * Return the Player's last loadout
 * 
 * @param   class'Julia.Player' Player
 * @return  class'DynamicLoadoutSpec'
 */
static function DynamicLoadoutSpec GetPlayerLoadout(Julia.Player Player)
{
    if (Player.GetLastValidPawn() != None)
    {
        return NetPlayer(Player.GetLastValidPawn()).GetLoadoutSpec();
    }
    return None;
}

event Destroyed()
{
    if (self.Core != None)
    {
        self.Core.UnregisterInterestedInMissionEnded(self);
    }
    if (self.Client != None)
    {
        self.Client.Destroy();
        self.Client = None;
    }
    Super.Destroyed();
}

defaultproperties
{
    Title="Julia/Tracker";
    Version="1.2.0";
    LocaleClass=class'Locale';

    Attempts=3;
    Feedback=true;
    Compatible=false;
}

/* vim: set ft=java: */