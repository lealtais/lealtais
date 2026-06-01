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

      // [SPEAK THIS]: "We format the data into a beautiful Markdown table with the Leafs logo."
      final String nhlSection = '''
<!-- NHL-START -->
### 🍁 Toronto Maple Leafs - Last Game 🏒

| Game Date | Matchup | Score | Status |
| :--- | :--- | :--- | :--- |
| $gameDate | $awayTeam vs $homeTeam | **$awayScore - $homeScore** | 🔴 Final |

*Data automatically updated directly from the NHL API!*
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