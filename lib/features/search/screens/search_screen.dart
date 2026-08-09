import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';

import '../widgets/recent_search_tile.dart';
import '../widgets/search_empty.dart';
import '../widgets/search_error.dart';
import '../widgets/search_loading.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/suggested_contact_tile.dart';
import '/features/chat/screens/conversation_screen.dart';
import '/features/profile/screens/user_profile_screen.dart';
import '/core/services/storage_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}
int? currentUserId;
class _SearchScreenState
    extends State<SearchScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();
       int? currentUserId;

  @override
  void initState() {
    super.initState();
   _loadCurrentUser();


    Future.microtask(() {
      final provider =
          context.read<SearchProvider>();

      provider.loadRecentSearches();
      provider.loadSuggestedContacts();
    });
  }
Future<void> _loadCurrentUser() async {
  currentUserId =
      await StorageService.getUserId();

  if (mounted) {
    setState(() {});
  }
}
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding:
              const EdgeInsets.only(
            right: 16,
          ),
          child: TextField(
            controller:
                _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              provider.debouncedSearch(
                value,
              );
              setState(() {});
            },
            decoration:
                InputDecoration(
              hintText:
                  "Search chats, users, messages...",
              prefixIcon:
                  const Icon(Icons.search),
              suffixIcon:
                  _searchController
                          .text
                          .isNotEmpty
                      ? IconButton(
                          icon:
                              const Icon(
                            Icons.clear,
                          ),
                          onPressed: () {
                            _searchController
                                .clear();

                            provider.clear();

                            setState(() {});
                          },
                        )
                      : null,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
  onRefresh: () async {
    await provider.loadRecentSearches();
    await provider.loadSuggestedContacts();

    if (_searchController.text.isNotEmpty) {
      await provider.liveSearch(
        _searchController.text,
      );
    }
  },
  child: provider.loading
      ? SearchLoading()
      : provider.error != null
          ? SearchError(
              message: provider.error!,
            )
          : _buildBody(provider),
),
    );
  }

  Widget _buildBody(
    SearchProvider provider,
  ) {
    final hasSearch =
        _searchController.text
            .trim()
            .isNotEmpty;

    if (!hasSearch) {
      return ListView(
        padding:
            const EdgeInsets.all(16),
        children: [

          const Text(
            "Recent Searches",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (provider
              .recentSearches
              .isEmpty)
            const Padding(
              padding:
                  EdgeInsets.only(
                bottom: 25,
              ),
              child: Text(
                "No recent searches",
              ),
            ),

          ...provider.recentSearches
              .map(
                (search) =>
                    RecentSearchTile(
                  text:
                      search.searchText,
                  onTap: () {
                    _searchController
                        .text = search
                            .searchText;

                    provider
                        .debouncedSearch(
                      search.searchText,
                    );

                    setState(() {});
                  },
                  onDelete: () {
                    provider
                        .deleteRecentSearch(
                      search.id,
                    );
                  },
                ),
              ),

          const SizedBox(height: 30),

          const Text(
            "Suggested Contacts",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (provider
              .suggestedContacts
              .isEmpty)
            const Text(
              "No suggestions",
            ),

          ...provider
              .suggestedContacts
              .map(
                (user) =>
                    SuggestedContactTile(
                  fullName:
                      user.fullName,
                  username:
                      user.username,
                  profilePicture:
                      user
                          .profilePicture,
                  isOnline:
                      user.isOnline,
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UserProfileScreen(
        userId: int.parse(user.id),
      ),
    ),
  );
},
                ),
              ),
        ],
      );
    }

    final result =
        provider.liveResults;

    if (result == null) {
      return const SearchLoading();
    }

    return ListView(
      padding:
          const EdgeInsets.all(16),
      children: [

        //============================
        // USERS
        //============================

        if (result.users.isNotEmpty)
          Padding(
  padding: const EdgeInsets.only(
    bottom: 10,
  ),
  child: AnimatedSwitcher(
    duration: const Duration(
      milliseconds: 250,
    ),
    child: const Text(
      "Users",
      key: ValueKey("users"),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

        ...result.users.map(
          (user) =>
              TweenAnimationBuilder<double>(
  duration: const Duration(
    milliseconds: 250,
  ),
  tween: Tween(
    begin: 0,
    end: 1,
  ),
  builder: (_, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(
          0,
          20 * (1 - value),
        ),
        child: child,
      ),
    );
  },
  child: SearchResultTile(
    searchQuery: _searchController.text,
    leading: CircleAvatar(
      backgroundImage: user.profilePicture != null
          ? NetworkImage(user.profilePicture!)
          : null,
      child: user.profilePicture == null
          ? const Icon(Icons.person)
          : null,
    ),
    title: user.fullName,
    subtitle: "@${user.username}",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(
            userId: user.id,
          ),
        ),
      );
    },
  ),
)
        ),

        //============================
        // CHATS
        //============================

        if (result.chats.isNotEmpty)
          Padding(
  padding: const EdgeInsets.only(
    top: 20,
    bottom: 10,
  ),
  child: AnimatedSwitcher(
    duration: const Duration(
      milliseconds: 250,
    ),
    child: const Text(
      "Chats",
      key: ValueKey("chats"),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

        ...result.chats.map(
          (chat) =>
          TweenAnimationBuilder<double>(
  duration: const Duration(milliseconds: 250),
  tween: Tween(begin: 0, end: 1),
  builder: (_, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    );
  },
              child: SearchResultTile(
                searchQuery: _searchController.text,
            leading:
                CircleAvatar(
              backgroundImage:
                  chat.profilePicture !=
                          null
                      ? NetworkImage(
                          chat
                              .profilePicture!,
                        )
                      : null,
            ),
            title:
                chat.fullName,
            subtitle:
                chat.lastMessage ??
                    "",
            onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ConversationScreen(
        conversationId: int.tryParse(chat.conversationId),
        receiverId: int.tryParse(chat.receiverId) ?? 0,
        currentUserId: currentUserId ?? 0,
        chatName: chat.fullName,
        profileImage: chat.profilePicture,
        isOnline: chat.isOnline,
      ),
    ),
  );
},
              ),
          ),
        ),

        //============================
        // MESSAGES
        //============================

        if (result.messages.isNotEmpty)
          Padding(
  padding: const EdgeInsets.only(
    top: 20,
    bottom: 10,
  ),
  child: AnimatedSwitcher(
    duration: const Duration(
      milliseconds: 250,
    ),
    child: const Text(
      "Messages",
      key: ValueKey("messages"),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

        ...result.messages.map(
          (message) =>
          TweenAnimationBuilder<double>(
  duration: const Duration(milliseconds: 250),
  tween: Tween(begin: 0, end: 1),
  builder: (_, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    );
  },
              child: SearchResultTile(
                searchQuery: _searchController.text,
            leading:
                const Icon(
              Icons.message,
            ),
            title:
                message.senderName,
            subtitle:
                message.message,
            onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ConversationScreen(
        conversationId: int.tryParse(message.conversationId),
        receiverId: currentUserId ?? 0,
        isOnline: false,
        currentUserId: currentUserId ?? 0,
        chatName: message.senderName,
      ),
    ),
  );
},
              ),
          ),
        ),

        if (result.users.isEmpty &&
            result.chats.isEmpty &&
            result.messages.isEmpty)
          SearchEmpty(),
      ],
    );
  }
}