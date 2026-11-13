import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/theme/glass_theme.dart';
import '../../data/models/city.dart';
import '../city/city_page.dart';
import '../widgets/page_header.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_surfaces.dart';

/// Search for Brazilian municipalities and star them as favorites.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.services});

  final AppServices services;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _debounce = Duration(milliseconds: 400);
  static const _minChars = 2;

  final _controller = TextEditingController();
  Timer? _timer;

  String _query = '';
  bool _loading = false;
  bool _error = false;
  List<City>? _results;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    final query = text.trim();
    if (query == _query) return;
    _timer?.cancel();
    setState(() {
      _query = query;
      _error = false;
      _results = null;
      _loading = query.length >= _minChars;
    });
    if (query.length >= _minChars) {
      _timer = Timer(_debounce, () => _search(query));
    }
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = false;
    });
    List<City>? results;
    try {
      results = await widget.services.geocodingApi.search(query);
    } catch (_) {
      results = null;
    }
    // Drop the response if the text changed while it was in flight.
    if (!mounted || query != _query) return;
    setState(() {
      _loading = false;
      _error = results == null;
      _results = results;
    });
  }

  void _openCity(City city) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CityPage(services: widget.services, city: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: ContentLayout(
            builder: (context, side) => Column(
              children: [
                PageHeader(
                  sidePadding: side,
                  title: 'Buscar município',
                  leading: GlassIconButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Voltar',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: side),
                  child: GlassPanel(
                    borderRadius: BorderRadius.circular(
                      GlassMetrics.wellRadius,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: _onChanged,
                        textInputAction: TextInputAction.search,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          color: GlassColors.ink,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Nome do município',
                          labelStyle: const TextStyle(
                            color: GlassColors.inkMuted,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: GlassColors.accent,
                          ),
                          icon: const Icon(
                            Icons.search,
                            color: GlassColors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildBody(side)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double side) {
    if (_query.length < _minChars) {
      return _Message(
        sidePadding: side,
        icon: Icons.location_city,
        message: 'Digite o nome de um município',
      );
    }
    if (_error) {
      return _Message(
        sidePadding: side,
        icon: Icons.cloud_off,
        iconColor: GlassColors.danger,
        message: 'Não foi possível buscar. Verifique sua conexão.',
        actionLabel: 'Tentar novamente',
        onAction: () => _search(_query),
      );
    }
    final results = _results;
    if (_loading || results == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.isEmpty) {
      return _Message(
        sidePadding: side,
        icon: Icons.search,
        message: "Nenhum município encontrado para '$_query'",
      );
    }

    final favorites = widget.services.favorites;
    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) => ListView.separated(
        padding: EdgeInsets.fromLTRB(side, 4, side, 32),
        itemCount: results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final city = results[index];
          final isFavorite = favorites.isFavorite(city);
          return GlassCard(
            key: ValueKey(city.id),
            onTap: () => _openCity(city),
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.place,
                  color: GlassColors.ink,
                  shadows: GlassShadows.text,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(city.name, style: GlassText.title),
                      if (city.admin1.isNotEmpty)
                        Text(city.admin1, style: GlassText.label),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GlassIconButton(
                  icon: isFavorite ? Icons.star : Icons.star_border,
                  iconColor: isFavorite ? GlassColors.accent : GlassColors.ink,
                  tooltip: isFavorite
                      ? 'Remover ${city.name} dos favoritos'
                      : 'Adicionar ${city.name} aos favoritos',
                  onTap: () => favorites.toggle(city),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    required this.sidePadding,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double sidePadding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      child: GlassNotice(
        icon: icon,
        iconColor: iconColor,
        message: message,
        actionLabel: actionLabel,
        actionIcon: actionLabel == null ? null : Icons.refresh,
        onAction: onAction,
      ),
    );
  }
}
