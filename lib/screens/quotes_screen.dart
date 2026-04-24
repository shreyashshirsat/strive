import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  String _quote = "Success is not final, failure is not fatal: it is the courage to continue that counts.";
  String _author = "Winston Churchill";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to load the cached quote first
    setState(() {
      _quote = prefs.getString('last_quote_text') ?? _quote;
      _author = prefs.getString('last_quote_author') ?? _author;
    });

    try {
      // Fetch new quote of the day
      final response = await http.get(Uri.parse('https://zenquotes.io/api/today'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final String newQuote = data[0]['q'];
          final String newAuthor = data[0]['a'];

          setState(() {
            _quote = newQuote;
            _author = newAuthor;
          });

          // Cache the successfully fetched quote
          await prefs.setString('last_quote_text', newQuote);
          await prefs.setString('last_quote_author', newAuthor);
        }
      }
    } catch (e) {
      // In case of no internet or error, we stick with the cached version
      debugPrint("Error fetching quote: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Strive",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading && _quote == "Success is not final, failure is not fatal: it is the courage to continue that counts.")
              const Center(child: CircularProgressIndicator())
            else
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _quote,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "— $_author",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () {
                // Share functionality can be added later
              },
              icon: const Icon(Icons.share),
              label: const Text("Share Quote"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
