import 'package:flutter/material.dart';

import '../models/duty_post.dart';

class DutyPostCard extends StatelessWidget {
  final DutyPost post;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DutyPostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(40),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.place, color: Colors.blue),
        ),
        title: Text(
          post.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        // subtitle: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     SizedBox(height: 2),
        //     if (post.name != null && post.name!.isNotEmpty)
        //       Text(post.name!),
        //     if (post.id != null && post.id!.isNotEmpty)
        //       Text(
        //         post.id!,
        //         style: TextStyle(fontSize: 12),
        //         maxLines: 2,
        //         overflow: TextOverflow.ellipsis,
        //       ),
        //   ],
        // ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
