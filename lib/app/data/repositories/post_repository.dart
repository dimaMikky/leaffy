import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:twitter_alternative/app/data/models/post_model.dart';
import 'package:twitter_alternative/app/data/providers/supabase_provider.dart';
import 'package:twitter_alternative/core/services/file_service.dart';
import 'package:get/get.dart';

class PostRepository {
  final SupabaseProvider _supabaseProvider;
  // Get the FileService from GetX
  final FileService _fileService = Get.find<FileService>();

  PostRepository({
    required SupabaseProvider supabaseProvider,
  }) : _supabaseProvider = supabaseProvider;
// Get posts for the feed with pagination
  Future<List<PostModel>> getFeedPosts({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();

      // Get posts with author information
      final response = await _supabaseProvider.client
          .from('posts')
          .select('''
          *,
          author:profiles(*)
        ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Properly cast each element to PostModel
      final List<PostModel> posts = [];
      for (var post in response) {
        posts.add(PostModel.fromJson({
          ...post,
          'author': post['author'],
        }));
      }

      // If user is logged in, check their reactions to these posts
      if (currentUser != null && posts.isNotEmpty) {
        final postIds = posts.map((post) => post.id).toList();

        final reactionsResponse = await _supabaseProvider.client
            .from('reactions')
            .select('post_id, reaction_type')
            .eq('user_id', currentUser.id)
            .in_('post_id', postIds);

        final reactionsMap = {
          for (var reaction in reactionsResponse)
            reaction['post_id'] as String: reaction['reaction_type'] as String
        };

        return posts
            .map((post) => post.copyWith(
                  userReaction: reactionsMap[post.id],
                ))
            .toList();
      }

      return posts; // Already properly typed as List<PostModel>
    } catch (e) {
      print("❌ Error getting feed posts: $e");
      rethrow;
    }
  }

// Get posts by a specific user
  Future<List<PostModel>> getUserPosts({
    required String userId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();

      // Get posts with author information
      final response = await _supabaseProvider.client
          .from('posts')
          .select('''
          *,
          author:profiles(*)
        ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Properly create a typed list instead of casting
      final List<PostModel> posts = [];
      for (var post in response) {
        posts.add(PostModel.fromJson({
          ...post,
          'author': post['author'],
        }));
      }

      // If user is logged in, check their reactions to these posts
      if (currentUser != null && posts.isNotEmpty) {
        final postIds = posts.map((post) => post.id).toList();

        final reactionsResponse = await _supabaseProvider.client
            .from('reactions')
            .select('post_id, reaction_type')
            .eq('user_id', currentUser.id)
            .in_('post_id', postIds);

        final reactionsMap = {
          for (var reaction in reactionsResponse)
            reaction['post_id'] as String: reaction['reaction_type'] as String
        };

        // Create a new list with user reactions
        final List<PostModel> postsWithReactions = [];
        for (var post in posts) {
          postsWithReactions.add(post.copyWith(
            userReaction: reactionsMap[post.id],
          ));
        }

        return postsWithReactions;
      }

      return posts; // Already properly typed as List<PostModel>
    } catch (e) {
      print("❌ Error getting user posts: $e");
      rethrow;
    }
  }

  // Create a new post
  Future<PostModel> createPost({
    required String content,
    File? image,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      String? imageUrl;

      // Handle image upload for both platforms
      if (image != null || (imageBytes != null && imageName != null)) {
        if (kIsWeb && imageBytes != null && imageName != null) {
          // Web platform upload
          imageUrl = await _fileService.uploadFile(
            bucketName: 'post_images',
            fileName: imageName,
            bytes: imageBytes,
            contentType: 'image/jpeg', // Adjust based on your image type
          );
        } else if (!kIsWeb && image != null) {
          // Mobile platform upload - read file as bytes
          final bytes = await image.readAsBytes();
          final fileName = path.basename(image.path);

          imageUrl = await _fileService.uploadFile(
            bucketName: 'post_images',
            fileName: fileName,
            bytes: bytes,
          );
        }
      }

      // Create post in database
      final postData = {
        'user_id': currentUser.id,
        'content': content,
        'image_url': imageUrl,
      };

      final response = await _supabaseProvider.client
          .from('posts')
          .insert(postData)
          .select()
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing post
  Future<PostModel> updatePost({
    required String postId,
    required String content,
    File? image,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get existing post to check ownership
      final existingPost = await _supabaseProvider.client
          .from('posts')
          .select()
          .eq('id', postId)
          .single();

      final post = PostModel.fromJson(existingPost);
      if (post.userId != currentUser.id) {
        throw Exception('Not authorized to update this post');
      }

      String? imageUrl = post.imageUrl;

      // Handle image update
      if (image != null || (imageBytes != null && imageName != null)) {
        // If there's an existing image, delete it
        if (post.imageUrl != null) {
          final oldImageName = _fileService.getFileNameFromUrl(post.imageUrl!);
          await _fileService.deleteFile(
            bucketName: 'post_images',
            filePath: oldImageName,
          );
        }

        // Upload new image
        if (kIsWeb && imageBytes != null && imageName != null) {
          // Web platform upload
          imageUrl = await _fileService.uploadFile(
            bucketName: 'post_images',
            fileName: imageName,
            bytes: imageBytes,
            contentType: 'image/jpeg',
          );
        } else if (!kIsWeb && image != null) {
          // Mobile platform upload
          final bytes = await image.readAsBytes();
          final fileName = path.basename(image.path);

          imageUrl = await _fileService.uploadFile(
            bucketName: 'post_images',
            fileName: fileName,
            bytes: bytes,
          );
        }
      }

      // Update post in database
      final postData = {
        'content': content,
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseProvider.client
          .from('posts')
          .update(postData)
          .eq('id', postId)
          .select()
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get existing post to check ownership and get image URL if any
      final existingPost = await _supabaseProvider.client
          .from('posts')
          .select()
          .eq('id', postId)
          .single();

      final post = PostModel.fromJson(existingPost);
      if (post.userId != currentUser.id) {
        throw Exception('Not authorized to delete this post');
      }

      // Delete post's image if it exists
      if (post.imageUrl != null) {
        final imageName = _fileService.getFileNameFromUrl(post.imageUrl!);
        await _fileService.deleteFile(
          bucketName: 'post_images',
          filePath: imageName,
        );
      }

      // Delete reactions to this post
      await _supabaseProvider.client
          .from('reactions')
          .delete()
          .eq('post_id', postId);

      // Delete the post
      await _supabaseProvider.client.from('posts').delete().eq('id', postId);
    } catch (e) {
      rethrow;
    }
  }

  // Get a single post by ID
  Future<PostModel> getPostById(String postId) async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();

      // Get post with author information
      final response = await _supabaseProvider.client.from('posts').select('''
            *,
            author:profiles(*)
          ''').eq('id', postId).single();

      final post = PostModel.fromJson({
        ...response,
        'author': response['author'],
      });

      // If user is logged in, check if they've reacted to this post
      if (currentUser != null) {
        final reactionResponse = await _supabaseProvider.client
            .from('reactions')
            .select('reaction_type')
            .eq('user_id', currentUser.id)
            .eq('post_id', postId)
            .maybeSingle();

        if (reactionResponse != null) {
          return post.copyWith(
            userReaction: reactionResponse['reaction_type'] as String,
          );
        }
      }

      return post;
    } catch (e) {
      rethrow;
    }
  }

  // Add or update a reaction
  Future<void> reactToPost({
    required String postId,
    required String reactionType,
  }) async {
    try {
      final currentUser = _supabaseProvider.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final existingReaction = await _supabaseProvider.client
          .from('reactions')
          .select()
          .eq('user_id', currentUser.id)
          .eq('post_id', postId)
          .maybeSingle();

      if (existingReaction != null) {
        // If it's the same reaction, remove it (toggle off)
        if (existingReaction['reaction_type'] == reactionType) {
          await _supabaseProvider.client
              .from('reactions')
              .delete()
              .eq('id', existingReaction['id']);
        } else {
          // Otherwise update to the new reaction type
          await _supabaseProvider.client.from('reactions').update(
              {'reaction_type': reactionType}).eq('id', existingReaction['id']);
        }
      } else {
        // Create a new reaction
        await _supabaseProvider.client.from('reactions').insert({
          'user_id': currentUser.id,
          'post_id': postId,
          'reaction_type': reactionType,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get a stream of real-time updates for a specific post
  Stream<PostModel> getPostStream(String postId) {
    try {
      final stream = _supabaseProvider.client
          .from('posts')
          .stream(primaryKey: ['id'])
          .eq('id', postId)
          .map((event) => PostModel.fromJson(event.first));

      return stream;
    } catch (e) {
      rethrow;
    }
  }
}
