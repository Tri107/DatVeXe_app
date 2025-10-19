class TripInfoDTO {
  final int ticketId;
  final num price;
  final String nhaXe;
  final String loaiXe;
  final String bienSo;
  final String gioDi;
  final String benDi;
  final String benDen;
  final String khName;
  final String khSdt;
  final String khEmail;

  TripInfoDTO({
    required this.ticketId,
    required this.price,
    required this.nhaXe,
    required this.loaiXe,
    required this.bienSo,
    required this.gioDi,
    required this.benDi,
    required this.benDen,
    required this.khName,
    required this.khSdt,
    required this.khEmail,
  });

  factory TripInfoDTO.fromSummary(Map<String, dynamic> j) {
    final t = j['ticket'] ?? {};
    final c = j['customer'] ?? {};
    final trip = j['trip'] ?? {};
    final route = trip['route'] ?? {};
    final from = route['from'] ?? {};
    final to = route['to'] ?? {};
    final v = j['vehicle'] ?? {};
    return TripInfoDTO(
      ticketId: (t['id'] ?? 0) as int,
      price: num.tryParse('${t['price']}') ?? 0,
      nhaXe: '${trip['name'] ?? ''}',
      loaiXe: '${v['typeName'] ?? ''}',
      bienSo: '${v['plate'] ?? ''}',
      gioDi: '${trip['departTime'] ?? ''}',
      benDi: '${from['name'] ?? ''}',
      benDen: '${to['name'] ?? ''}',
      khName: '${c['name'] ?? ''}',
      khSdt: '${c['phone'] ?? ''}',
      khEmail: '${c['email'] ?? ''}',
    );
  }
}
