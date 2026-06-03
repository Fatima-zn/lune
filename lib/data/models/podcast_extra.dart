class PodcastExtra {
  final String? url1;
  final String? url2;
  final String? url3;
  final String? spotifyUrl;
  final String? youtubeUrl;
  final String? linkedinUrl;
  final String? wechatHandle;
  final String? patreonHandle;
  final String? twitterHandle;
  final String? facebookHandle;
  final String? amazonMusicUrl;
  final String? instagramHandle;

  const PodcastExtra({
    this.url1,
    this.url2,
    this.url3,
    this.spotifyUrl,
    this.youtubeUrl,
    this.linkedinUrl,
    this.wechatHandle,
    this.patreonHandle,
    this.twitterHandle,
    this.facebookHandle,
    this.amazonMusicUrl,
    this.instagramHandle,
  });

  factory PodcastExtra.fromJson(Map<String, dynamic> json) {
    return PodcastExtra(
      url1: json['url1'] as String?,
      url2: json['url2'] as String?,
      url3: json['url3'] as String?,
      spotifyUrl: json['spotify_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      wechatHandle: json['wechat_handle'] as String?,
      patreonHandle: json['patreon_handle'] as String?,
      twitterHandle: json['twitter_handle'] as String?,
      facebookHandle: json['facebook_handle'] as String?,
      amazonMusicUrl: json['amazon_music_url'] as String?,
      instagramHandle: json['instagram_handle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (url1 != null) 'url1': url1,
      if (url2 != null) 'url2': url2,
      if (url3 != null) 'url3': url3,
      if (spotifyUrl != null) 'spotify_url': spotifyUrl,
      if (youtubeUrl != null) 'youtube_url': youtubeUrl,
      if (linkedinUrl != null) 'linkedin_url': linkedinUrl,
      if (wechatHandle != null) 'wechat_handle': wechatHandle,
      if (patreonHandle != null) 'patreon_handle': patreonHandle,
      if (twitterHandle != null) 'twitter_handle': twitterHandle,
      if (facebookHandle != null) 'facebook_handle': facebookHandle,
      if (amazonMusicUrl != null) 'amazon_music_url': amazonMusicUrl,
      if (instagramHandle != null) 'instagram_handle': instagramHandle,
    };
  }
}