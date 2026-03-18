import 'package:festum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProviderBusinessInfoView extends StatelessWidget {
  const ProviderBusinessInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completar información\ndel negocio',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ayuda a que los clientes conozcan mejor tu servicio.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
            ),
            const SizedBox(height: 32),
            _SectionTitle(title: 'Detalles del negocio'),
            const SizedBox(height: 16),
            _CustomTextField(
              hintText: 'Ingrese nombre del negocio',
            ),
            const SizedBox(height: 16),
            _CustomDropdownField(
              hintText: 'Tipo de servicio',
              items: const ['Salones', 'Mobiliario', 'Banquetes', 'Decoración'],
            ),
            const SizedBox(height: 8),
            Text(
              'Seleccione tipo de servicio',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
            ),
            const SizedBox(height: 24),
            _InfoCard(
              title: 'Ubicación',
              subtitle: 'Ciudad o zona donde trabaja',
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Área de cobertura',
              subtitle: 'Ej: Teziutlán y municipios cercanos',
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              hintText: 'Número de contacto',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            _SocialNetworkSection(),
            const SizedBox(height: 32),
            _SectionTitle(title: 'Fotos del negocio'),
            const SizedBox(height: 16),
            _LogoUploadCard(),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appBar,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar y continuar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;

  const _CustomTextField({required this.hintText, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _CustomDropdownField extends StatelessWidget {
  final String hintText;
  final List<String> items;

  const _CustomDropdownField({required this.hintText, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hintText, style: const TextStyle(color: Colors.black38)),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SocialNetworkSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Página web y redes sociales', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('opcional', style: TextStyle(color: AppColors.secondaryText.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SocialIcon(icon: Icons.phone),
              const SizedBox(width: 12),
              _SocialIcon(icon: Icons.video_library),
              const SizedBox(width: 12),
              _SocialIcon(icon: Icons.language),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.appBar),
    );
  }
}

class _LogoUploadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_a_photo_outlined, color: AppColors.secondaryText),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Añadir logo del negocio', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Añadir fotos de trabajos', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.more_horiz, color: AppColors.secondaryText),
        ],
      ),
    );
  }
}
