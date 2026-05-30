import 'package:flutter/material.dart';

import '../models/hotel_model.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback? onTap;

  const HotelCard({
    super.key,
    required this.hotel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        margin:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius:
                  const BorderRadius.only(
                topLeft:
                    Radius.circular(16),
                topRight:
                    Radius.circular(16),
              ),
              child: Image.network(
                hotel.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      context,
                      error,
                      stackTrace,
                    ) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.hotel,
                        size: 60,
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [

                  Text(
                    hotel.name,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          hotel.location,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    hotel.desc,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [

                      Text(
                        'Rp ${hotel.price}',
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.blue,
                        ),
                      ),

                      Chip(
                        label: Text(
                          hotel.category,
                        ),
                      ),
                    ],
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