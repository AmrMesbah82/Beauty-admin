// ******************* FILE INFO *******************
// File Name: comment_local.dart
// Description: Comment local state helpers for Overview edit
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › overview › presentation › ui › widget › overview_edit

part of '../../pages/overview_edit.dart';

class _CommentLocal {
  final String id;
  final TextEditingController firstNameEn;
  final TextEditingController firstNameAr;
  final TextEditingController lastNameEn;
  final TextEditingController lastNameAr;
  final TextEditingController feedbackEn;
  final TextEditingController feedbackAr;
  _PickedImage image;

  _CommentLocal({required this.id})
      : firstNameEn = TextEditingController(),
        firstNameAr = TextEditingController(),
        lastNameEn  = TextEditingController(),
        lastNameAr  = TextEditingController(),
        feedbackEn  = TextEditingController(),
        feedbackAr  = TextEditingController(),
        image = const _PickedImage();

  void dispose() {
    firstNameEn.dispose();
    firstNameAr.dispose();
    lastNameEn.dispose();
    lastNameAr.dispose();
    feedbackEn.dispose();
    feedbackAr.dispose();
  }
}
