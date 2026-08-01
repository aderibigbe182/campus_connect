import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider =
          context.read<SearchProvider>();

      provider.loadRecentSearches();
      provider.loadSuggestedContacts();
    });
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
            onChanged: (value) {
              provider
                  .debouncedSearch(
                value,
              );
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

                            provider
                                .clear();

                            setState(() {});
                          },
                        )
                      : null,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  30,
                ),
              ),
            ),
          ),
        ),
      ),

      body: provider.loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : provider.error != null
              ? Center(
                  child: Text(
                    provider.error!,
                  ),
                )
              : _buildBody(provider),
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
                    ListTile(
                  leading:
                      const Icon(
                    Icons.history,
                  ),
                  title: Text(
                    search
                        .searchText,
                  ),
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
                    ListTile(
                  leading:
                      CircleAvatar(
                    backgroundImage:
                        user.profilePicture !=
                                null
                            ? NetworkImage(
                                user.profilePicture!,
                              )
                            : null,
                    child: user
                                .profilePicture ==
                            null
                        ? const Icon(
                            Icons.person,
                          )
                        : null,
                  ),
                  title: Text(
                    user.fullName,
                  ),
                  subtitle: Text(
                    "@${user.username}",
                  ),
                  trailing: Icon(
                    Icons.circle,
                    size: 12,
                    color: user
                            .isOnline
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
        ],
      );
    }

    final result =
        provider.liveResults;

    if (result == null) {
      return const Center(
        child: Text(
          "Searching...",
        ),
      );
    }

    return ListView(
      padding:
          const EdgeInsets.all(16),
      children: [

        if (result.users.isNotEmpty)
          const Padding(
            padding:
                EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              "Users",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

        ...result.users.map(
          (user) => ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.profilePicture !=
                          null
                      ? NetworkImage(
                          user
                              .profilePicture!,
                        )
                      : null,
              child:
                  user.profilePicture ==
                          null
                      ? const Icon(
                          Icons.person,
                        )
                      : null,
            ),
            title:
                Text(user.fullName),
            subtitle:
                Text("@${user.username}"),
          ),
        ),

        if (result.chats.isNotEmpty)
          const Padding(
            padding:
                EdgeInsets.only(
              top: 20,
              bottom: 10,
            ),
            child: Text(
              "Chats",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

        ...result.chats.map(
          (chat) => ListTile(
            leading:
                CircleAvatar(
              backgroundImage:
                  chat.profilePicture !=
                          null
                      ? NetworkImage(
                          chat.profilePicture!,
                        )
                      : null,
            ),
            title:
                Text(chat.fullName),
            subtitle: Text(
              chat.lastMessage ??
                  "",
            ),
          ),
        ),

        if (result.messages
            .isNotEmpty)
          const Padding(
            padding:
                EdgeInsets.only(
              top: 20,
              bottom: 10,
            ),
            child: Text(
              "Messages",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

        ...result.messages.map(
          (message) =>
              ListTile(
            leading: const Icon(
              Icons.message,
            ),
            title: Text(
              message.senderName,
            ),
            subtitle: Text(
              message.message,
            ),
          ),
        ),

        if (result.users.isEmpty &&
            result.chats.isEmpty &&
            result.messages.isEmpty)
          const Padding(
            padding:
                EdgeInsets.only(
              top: 40,
            ),
            child: Center(
              child: Text(
                "No results found",
              ),
            ),
          ),
      ],
    );
  }
}