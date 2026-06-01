// [SPEAK THIS]: "First, we import the file system and HTTP packages to read files and make API requests."
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // [SPEAK THIS]: "We define the NHL API endpoint for the Toronto Maple Leafs club schedule."
  const String url = 'https://api-web.nhle.com/v1/club-schedule-season/TOR/now';
  const String readmePath = '../README.md';

  print("Fetching Toronto Maple Leafs data...");

  try {
    // [SPEAK THIS]: "We send a GET request to the NHL API and wait for the response."
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List games = data['games'] ?? [];

      if (games.isEmpty) {
        print("No games found.");
        return;
      }

      // [SPEAK THIS]: "We find the most recent game played by the Leafs."
      Map? lastGame;
      for (var game in games.reversed) {
        if (game['gameState'] == 'OFF' || game['gameState'] == 'FINAL') {
          lastGame = game;
          break;
        }
      }

      if (lastGame == null) {
        print("Could not find any completed games.");
        return;
      }

      // [SPEAK THIS]: "We extract the team names, logos, and scores from the API data."
      final homeTeam = lastGame['homeTeam']['placeName']['default'];
      final awayTeam = lastGame['awayTeam']['placeName']['default'];
      final homeScore = lastGame['homeTeam']['score'];
      final awayScore = lastGame['awayTeam']['score'];
      final gameDate = lastGame['gameDate'];

      // [SPEAK THIS]: "We calculate the countdown to the next NHL Season kickoff dynamically."
      final nextSeasonDate = DateTime(2026, 10, 8);
      final currentDate = DateTime.now();
      final daysRemaining = nextSeasonDate.difference(currentDate).inDays;

      // [SPEAK THIS]: "We format the data into a premium HTML side-by-side scorecard with the official logo and a countdown."
      final String nhlSection = '''
<!-- NHL-START -->
<div align="center">
  <table border="0" style="border-collapse: collapse; border: none; background: transparent;">
    <tr style="border: none; background: transparent;">
      <td width="160" align="center" valign="middle" style="border: none; background: transparent;">
        <img src="https://upload.wikimedia.org/wikipedia/en/thumb/b/b6/Toronto_Maple_Leafs_2016_logo.svg/512px-Toronto_Maple_Leafs_2016_logo.svg.png" width="130" alt="Toronto Maple Leafs Logo"/>
      </td>
      <td valign="middle" style="border: none; text-align: left; padding-left: 20px; background: transparent;">
        <h3 style="margin-top: 0; color: #0077B5;">🍁 Toronto Maple Leafs Live Tracker 🏒</h3>
        <p style="margin: 5px 0; font-size: 15px;"><b>Last Matchup:</b> $awayTeam vs $homeTeam</p>
        <p style="margin: 5px 0; font-size: 15px;"><b>Score:</b> <span style="background-color: #00205B; color: white; padding: 3px 8px; border-radius: 4px; font-weight: bold;"> $awayScore - $homeScore </span> &nbsp;🔴 Final ($gameDate)</p>
        <p style="margin: 5px 0; font-size: 14px; color: #0077B5;">⏳ <b>$daysRemaining days</b> until the 2026-27 NHL Season Kickoff!</p>
        <p style="margin: 5px 0; font-size: 11px; color: #888;"><i>Data automatically updated directly from the NHL API!</i></p>
      </td>
    </tr>
  </table>
</div>
<!-- NHL-END -->''';

      // [SPEAK THIS]: "Now, we open the README.md file, replace the markers with our new table, and save it."
      final File readmeFile = File(readmePath);
      if (await readmeFile.exists()) {
        String content = await readmeFile.readAsString();
        
        final regExp = RegExp(
          r'<!-- NHL-START -->([\s\S]*?)<!-- NHL-END -->',
          multiLine: true,
        );

        if (regExp.hasMatch(content)) {
          content = content.replaceAll(regExp, nhlSection);
          await readmeFile.writeAsString(content);
          print("README.md updated successfully with the Leafs score!");
        } else {
          print("Error: Could not find NHL markers in README.md.");
        }
      } else {
        print("Error: README.md not found at \$readmePath");
      }
    } else {
      print("Failed to fetch NHL data. Status code: \${response.statusCode}");
    }
  } catch (e) {
    print("Error running tracker: \$e");
  }
}
