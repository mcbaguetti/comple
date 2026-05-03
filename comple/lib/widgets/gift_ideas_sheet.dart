import 'package:flutter/material.dart';
import '../models/birthday.dart';
import '../services/storage_service.dart';

class GiftIdeasSheet extends StatefulWidget {
  final Birthday birthday;
  final StorageService storageService;

  const GiftIdeasSheet({
    Key? key,
    required this.birthday,
    required this.storageService,
  }) : super(key: key);

  @override
  State<GiftIdeasSheet> createState() => _GiftIdeasSheetState();
}

class _GiftIdeasSheetState extends State<GiftIdeasSheet> {
  final _giftController = TextEditingController();
  late List<String> _gifts;

  @override
  void initState() {
    super.initState();
    _gifts = List<String>.from(widget.birthday.gifts);
  }

  @override
  void dispose() {
    _giftController.dispose();
    super.dispose();
  }

  void _addGift() async {
    final text = _giftController.text.trim();
    if (text.isEmpty) return;
    await widget.storageService.addGift(widget.birthday.id, text);
    setState(() {
      _gifts.add(text);
    });
    _giftController.clear();
  }

  void _removeGift(String gift) async {
    await widget.storageService.removeGift(widget.birthday.id, gift);
    setState(() {
      _gifts.remove(gift);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenH = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenH * 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.onSurface, width: 2.0),
          ),
        ),
        child: Column(
          children: [
            // ── HEADER ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
              child: Container(
                width: 25,
                height: 1.5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: colorScheme.onSurface, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'gift ideas for ${widget.birthday.name.toLowerCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0, thickness: 1.0),

            // ── INPUT ROW ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _giftController,
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'add a gift idea...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(color: colorScheme.onSurface),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _addGift(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _addGift,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('+',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // ── GIFT LIST ────────────────────────────────────────────────
            Expanded(
              child: _gifts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'no gift ideas yet',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      itemCount: _gifts.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 0.5,
                        color: colorScheme.onSurface.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) {
                        final gift = _gifts[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.circle,
                            size: 6,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                          title: Text(
                            gift,
                            style: TextStyle(
                                fontSize: 14, color: colorScheme.onSurface),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            onPressed: () => _removeGift(gift),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
