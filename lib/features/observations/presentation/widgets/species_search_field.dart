import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// A search field for finding species by scientific or common name.
///
/// Currently uses mock data - will be connected to a species database
/// or API in future phases.
class SpeciesSearchField extends StatefulWidget {
  const SpeciesSearchField({
    super.key,
    this.initialValue,
    required this.onSelected,
  });

  final String? initialValue;
  final ValueChanged<String?> onSelected;

  @override
  State<SpeciesSearchField> createState() => _SpeciesSearchFieldState();
}

class _SpeciesSearchFieldState extends State<SpeciesSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<SpeciesResult> _results = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _showResults = _focusNode.hasFocus && _results.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Species (preliminary ID)',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search species name...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onSelected(null);
                      setState(() => _results = []);
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (value) {
            // Allow free text entry
            if (value.isNotEmpty) {
              widget.onSelected(value);
              setState(() {
                _results = [];
                _showResults = false;
              });
              _focusNode.unfocus();
            }
          },
        ),

        // Results dropdown
        if (_showResults && _results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return ListTile(
                  title: Text(
                    result.scientificName,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  subtitle:
                      result.commonName != null ? Text(result.commonName!) : null,
                  onTap: () {
                    _controller.text = result.scientificName;
                    widget.onSelected(result.scientificName);
                    setState(() {
                      _results = [];
                      _showResults = false;
                    });
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),

        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),

        // Help text
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            'Search for species or type your own identification',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() {
        _results = [];
        _showResults = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // TODO: Replace with actual species database search
    // For now, use mock data with debounce
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final mockResults = _mockSpeciesSearch(query);

    setState(() {
      _results = mockResults;
      _showResults = _focusNode.hasFocus && mockResults.isNotEmpty;
      _isSearching = false;
    });
  }

  List<SpeciesResult> _mockSpeciesSearch(String query) {
    final allSpecies = [
      SpeciesResult('Cantharellus cibarius', 'Golden Chanterelle'),
      SpeciesResult('Cantharellus formosus', 'Pacific Golden Chanterelle'),
      SpeciesResult('Cantharellus cascadensis', 'Cascade Chanterelle'),
      SpeciesResult('Craterellus tubaeformis', 'Yellowfoot'),
      SpeciesResult('Craterellus cornucopioides', 'Black Trumpet'),
      SpeciesResult('Amanita muscaria', 'Fly Agaric'),
      SpeciesResult('Amanita phalloides', 'Death Cap'),
      SpeciesResult('Amanita pantherina', 'Panther Cap'),
      SpeciesResult('Boletus edulis', 'Porcini'),
      SpeciesResult('Boletus rex-veris', 'Spring King Bolete'),
      SpeciesResult('Laetiporus sulphureus', 'Chicken of the Woods'),
      SpeciesResult('Laetiporus conifericola', 'Conifer Chicken'),
      SpeciesResult('Morchella esculenta', 'Yellow Morel'),
      SpeciesResult('Morchella elata', 'Black Morel'),
      SpeciesResult('Grifola frondosa', 'Maitake'),
      SpeciesResult('Pleurotus ostreatus', 'Oyster Mushroom'),
      SpeciesResult('Pleurotus pulmonarius', 'Phoenix Oyster'),
      SpeciesResult('Hericium erinaceus', "Lion's Mane"),
      SpeciesResult('Hericium americanum', "Bear's Head"),
      SpeciesResult('Trametes versicolor', 'Turkey Tail'),
      SpeciesResult('Armillaria mellea', 'Honey Mushroom'),
      SpeciesResult('Russula brevipes', 'Short-Stemmed Russula'),
      SpeciesResult('Lactarius deliciosus', 'Saffron Milk Cap'),
      SpeciesResult('Agaricus campestris', 'Meadow Mushroom'),
    ];

    final lowerQuery = query.toLowerCase();
    return allSpecies
        .where((s) =>
            s.scientificName.toLowerCase().contains(lowerQuery) ||
            (s.commonName?.toLowerCase().contains(lowerQuery) ?? false),)
        .take(8)
        .toList();
  }
}

/// A species search result.
class SpeciesResult {

  SpeciesResult(this.scientificName, [this.commonName]);
  final String scientificName;
  final String? commonName;
}
