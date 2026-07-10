import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/planned_session_controller.dart';
import '../controllers/proof_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/proof.dart';
import '../widgets/empty_state.dart';
import '../widgets/proof_card.dart';
import 'edit_proof_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  void _openEditScreen(BuildContext context, Proof proof) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EditProofScreen(proof: proof),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Proof proof) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete proof?'),
          content: Text(
            'This will remove "${proof.title}" from your local timeline.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      final proofController = context.read<ProofController>();
      final plannedController = context.read<PlannedSessionController>();
      await proofController.deleteProof(proof.id);
      await plannedController.unlinkProof(proof.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proof deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProofController, SkillController>(
      builder: (context, controller, skillController, child) {
        final proofs = controller.proofs;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _TimelineHeader(totalProofs: controller.totalProofs),
            const SizedBox(height: 18),
            if (proofs.isEmpty)
              const EmptyState(
                icon: Icons.timeline_outlined,
                title: 'Your proof timeline starts here',
                message:
                    'Every proof you log becomes a portfolio breadcrumb. Add one and watch your build history take shape.',
              )
            else
              ...proofs.map(
                (proof) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ProofCard(
                    proof: proof,
                    skill: skillController.skillById(proof.skillId),
                    onTap: () => _openEditScreen(context, proof),
                    onEdit: () => _openEditScreen(context, proof),
                    onDelete: () => _confirmDelete(context, proof),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({required this.totalProofs});

  final int totalProofs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.20 : 0.08,
            ),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF07152F), Color(0xFF2457FF)],
              ),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(Icons.view_timeline, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proof timeline',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalProofs == 1
                      ? '1 logged proof, newest first.'
                      : '$totalProofs logged proofs, newest first.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
