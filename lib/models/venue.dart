class ProductMedia {
  final String url;
  final String distance;
  final String type;
  final bool isVideo;

  ProductMedia({
    required this.url,
    required this.distance,
    required this.type,
    required this.isVideo,
  });

  factory ProductMedia.fromJson(Map<String, dynamic> json) {
    return ProductMedia(
      url: json['url'] ?? '',
      distance: json['distance'] ?? '',
      type: json['type'] ?? '',
      isVideo: json['isVideo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'distance': distance,
      'type': type,
      'isVideo': isVideo,
    };
  }
}

class ProductSpecsRental {
  final String? location;
  final int? trafficCount;
  final String? trafficUnit;
  final double? elevation;
  final String? elevationUnit;
  final double? height;
  final double? width;
  final String? dimensionUnit;
  final String? audienceType;
  final List<String>? audienceTypes;
  final double? locationVisibility;
  final String? locationVisibilityUnit;
  final String? orientation;
  final String? partner;
  final String? landOwner;
  final List<double>? geopoint;
  final Map<String, dynamic>? illumination;
  final Map<String, dynamic>? structure;

  ProductSpecsRental({
    this.location,
    this.trafficCount,
    this.trafficUnit,
    this.elevation,
    this.elevationUnit,
    this.height,
    this.width,
    this.dimensionUnit,
    this.audienceType,
    this.audienceTypes,
    this.locationVisibility,
    this.locationVisibilityUnit,
    this.orientation,
    this.partner,
    this.landOwner,
    this.geopoint,
    this.illumination,
    this.structure,
  });

  factory ProductSpecsRental.fromJson(Map<String, dynamic> json) {
    return ProductSpecsRental(
      location: json['location'],
      trafficCount: json['traffic_count'],
      trafficUnit: json['traffic_unit'],
      elevation: json['elevation']?.toDouble(),
      elevationUnit: json['elevation_unit'],
      height: json['height']?.toDouble(),
      width: json['width']?.toDouble(),
      dimensionUnit: json['dimension_unit'],
      audienceType: json['audience_type'],
      audienceTypes: List<String>.from(json['audience_types'] ?? []),
      locationVisibility: json['location_visibility']?.toDouble(),
      locationVisibilityUnit: json['location_visibility_unit'],
      orientation: json['orientation'],
      partner: json['partner'],
      landOwner: json['land_owner'],
      geopoint: json['geopoint'] != null ? List<double>.from(json['geopoint']) : null,
      illumination: json['illumination'],
      structure: json['structure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'traffic_count': trafficCount,
      'traffic_unit': trafficUnit,
      'elevation': elevation,
      'elevation_unit': elevationUnit,
      'height': height,
      'width': width,
      'dimension_unit': dimensionUnit,
      'audience_type': audienceType,
      'audience_types': audienceTypes,
      'location_visibility': locationVisibility,
      'location_visibility_unit': locationVisibilityUnit,
      'orientation': orientation,
      'partner': partner,
      'land_owner': landOwner,
      'geopoint': geopoint,
      'illumination': illumination,
      'structure': structure,
    };
  }
}

class ProductLight {
  final String? location;
  final String? name;
  final String? operator;

  ProductLight({
    this.location,
    this.name,
    this.operator,
  });

  factory ProductLight.fromJson(Map<String, dynamic> json) {
    return ProductLight(
      location: json['location'],
      name: json['name'],
      operator: json['operator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'name': name,
      'operator': operator,
    };
  }
}

class Venue {
  final String id;
  final String iD; // Document ID
  final String name;
  final String type; // 'hotel' | 'church' | 'reception'
  final double price;
  final String location;
  final String? siteCode;
  final List<ProductMedia>? media;
  final ProductSpecsRental? specsRental;
  final ProductLight? light;
  final String? description;
  final double? healthPercentage;
  final String? additionalMessage;
  final bool? active;
  final bool? deleted;
  final DateTime? created;
  final DateTime? updated;
  final String? sellerId;
  final String? sellerName;
  final String? companyId;
  final int? position;
  final List<String>? categories;
  final List<String>? categoryNames;
  final String? contentType;
  final Map<String, dynamic>? cms;
  final String? status;
  final String? address;
  final double rating;
  final int reviewCount;
  final List<Map<String, dynamic>> availability;

  Venue({
    required this.id,
    required this.iD,
    required this.name,
    required this.type,
    required this.price,
    required this.location,
    this.siteCode,
    this.media,
    this.specsRental,
    this.light,
    this.description,
    this.healthPercentage,
    this.additionalMessage,
    this.active,
    this.deleted,
    this.created,
    this.updated,
    this.sellerId,
    this.sellerName,
    this.companyId,
    this.position,
    this.categories,
    this.categoryNames,
    this.contentType,
    this.cms,
    this.status,
    this.address,
    required this.rating,
    required this.reviewCount,
    required this.availability,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] ?? '',
      iD: json['ID'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'hotel',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      siteCode: json['site_code'],
      media: json['media'] != null
          ? List<ProductMedia>.from(json['media'].map((x) => ProductMedia.fromJson(x)))
          : null,
      specsRental: json['specs_rental'] != null
          ? ProductSpecsRental.fromJson(json['specs_rental'])
          : null,
      light: json['light'] != null ? ProductLight.fromJson(json['light']) : null,
      description: json['description'],
      healthPercentage: json['health_percentage']?.toDouble(),
      additionalMessage: json['additionalMessage'],
      active: json['active'],
      deleted: json['deleted'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      sellerId: json['seller_id'],
      sellerName: json['seller_name'],
      companyId: json['company_id'],
      position: json['position'],
      categories: json['categories'] != null ? List<String>.from(json['categories']) : null,
      categoryNames: json['category_names'] != null ? List<String>.from(json['category_names']) : null,
      contentType: json['content_type'],
      cms: json['cms'],
      status: json['status'],
      address: json['address'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      availability: json['availability'] != null
          ? List<Map<String, dynamic>>.from(json['availability'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ID': iD,
      'name': name,
      'type': type,
      'price': price,
      'location': location,
      'site_code': siteCode,
      'media': media?.map((x) => x.toJson()).toList(),
      'specs_rental': specsRental?.toJson(),
      'light': light?.toJson(),
      'description': description,
      'health_percentage': healthPercentage,
      'additionalMessage': additionalMessage,
      'active': active,
      'deleted': deleted,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'seller_id': sellerId,
      'seller_name': sellerName,
      'company_id': companyId,
      'position': position,
      'categories': categories,
      'category_names': categoryNames,
      'content_type': contentType,
      'cms': cms,
      'status': status,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'availability': availability,
    };
  }
}